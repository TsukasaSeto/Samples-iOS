//
//  ViewController.swift
//  FaceAuth
//
//  Created by Tsukasa Seto on 2018/10/11.
//  Copyright (c) 2018 Ricoh IT Solutions Co.,Ltd. All rights reserved.
//

import UIKit
import AVFoundation
import Vision

/// https://developer.apple.com/videos/play/wwdc2017/506/
extension CGImagePropertyOrientation {
    init(_ orientation: UIImage.Orientation) {
        switch orientation {
        case .up:
            self = .up
        case .upMirrored:
            self = .upMirrored
        case .down:
            self = .down
        case .downMirrored:
            self = .downMirrored
        case .left:
            self = .left
        case .leftMirrored:
            self = .leftMirrored
        case .right:
            self = .right
        case .rightMirrored:
            self = .rightMirrored
        }
    }
}

/// 画面上に認識矩形を描画するための custom view
class VisualizeRectanlgesView: UIView {
    
    var rectangles: [CGRect] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    var characterRectangles: [VNRectangleObservation] = [] {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private func convertedPoint(point: CGPoint, to size: CGSize) -> CGPoint {
        // view 上の座標に変換する
        // 座標系変換のため、 Y 軸方向に反転する
        return CGPoint(x: point.x * size.width, y: (1.0 - point.y) * size.height)
    }
    
    private func convertedRect(rect: CGRect, to size: CGSize) -> CGRect {
        // view 上の長方形に変換する
        // 座標系変換のため、 Y 軸方向に反転する
        return CGRect(x: rect.minX * size.width, y: (1.0 - rect.maxY) * size.height, width: rect.width * size.width, height: rect.height * size.height)
    }
    
    override func draw(_ rect: CGRect) {
        backgroundColor = UIColor.clear
        
        UIColor.blue.setStroke()
        
        for rect in characterRectangles {
            let path = UIBezierPath()
            path.lineWidth = 2
            path.move(to: convertedPoint(point: rect.topLeft, to: frame.size))
            path.addLine(to: convertedPoint(point: rect.topRight, to: frame.size))
            path.addLine(to: convertedPoint(point: rect.bottomRight, to: frame.size))
            path.addLine(to: convertedPoint(point: rect.bottomLeft, to: frame.size))
            path.addLine(to: convertedPoint(point: rect.topLeft, to: frame.size))
            path.close()
            path.stroke()
        }
        
        UIColor.red.setStroke()
        
        for rect in rectangles {
            let path = UIBezierPath(rect: convertedRect(rect: rect, to: frame.size))
            path.lineWidth = 2
            path.stroke()
        }
    }
}

class ViewController: UIViewController {

    private let captureSession = AVCaptureSession()
    private let imageView = UIImageView(frame: .zero)
    private let visualizeRectanglesView = VisualizeRectanlgesView(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        configureCaptureSettion()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startCaptureSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopCaptureSession()
    }
    
    private func setupView() {
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        view.addSubview(visualizeRectanglesView)
    }

    private func configureCaptureSettion() {
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .high
        
        // add video input
        guard let videoDevice = AVCaptureDevice.default(for: .video),
            let input = try? AVCaptureDeviceInput(device: videoDevice),
            captureSession.canAddInput(input) else {
                assertionFailure("Error: Cannot add input device.")
                return
        }
        captureSession.addInput(input)
        
        // add output
        let videoDataOutput = AVCaptureVideoDataOutput()
        guard captureSession.canAddOutput(videoDataOutput) else {
            print("Error: Cannot add output.")
            captureSession.commitConfiguration()
            return
        }
        videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String): Int(kCVPixelFormatType_32BGRA)]
        videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "video_data_output_queue"))
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        captureSession.addOutput(videoDataOutput)
        
        captureSession.commitConfiguration()
    }
    
    private func startCaptureSession() {
        guard !captureSession.isRunning else { return }
        captureSession.startRunning()
    }
    
    private func stopCaptureSession() {
        guard captureSession.isRunning else { return }
        captureSession.stopRunning()
    }

}


extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    private func createImage(from sampleBuffer: CMSampleBuffer) -> UIImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        
        CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags.readOnly)
        let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue
        let context = CGContext(data: baseAddress,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: bytesPerRow,
                                space: colorSpace,
                                bitmapInfo: bitmapInfo)
        let image = context?.makeImage()
        CVPixelBufferUnlockBaseAddress(imageBuffer, CVPixelBufferLockFlags.readOnly)
        guard let cgImage = image else { return nil }
        
        return UIImage(cgImage: cgImage)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let uiImage = createImage(from: sampleBuffer)
        
        var image: UIImage? = nil
        if UIApplication.shared.statusBarOrientation == .landscapeLeft {
            image = UIImage(cgImage: uiImage!.cgImage!, scale: 1.0, orientation: .down)
        } else if UIApplication.shared.statusBarOrientation == .landscapeRight {
            image = UIImage(cgImage: uiImage!.cgImage!, scale: 1.0, orientation: .up)
        } else {
            image = UIImage(cgImage: uiImage!.cgImage!, scale: 1.0, orientation: .right)
        }
        let orientation = CGImagePropertyOrientation(rawValue: UInt32(image!.imageOrientation.rawValue))
        let ciImage = CIImage(image: image!)!

        // UI の変更はメインスレッドで実行
        DispatchQueue.main.async { [weak self] in
            self?.imageView.image = image
        }

        // orientation を必ず設定すること
        let imageRequestHandler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation!)
        let request = VNDetectFaceRectanglesRequest() { request, error in
            // テキストブロックの矩形を取得
            let rects = request.results?.flatMap { result -> [CGRect] in
                guard let observation = result as? VNFaceObservation else { return [] }
                return [observation.boundingBox]
                } ?? []
            // UI の変更はメインスレッドで実行
            DispatchQueue.main.async { [weak self] in
                self?.visualizeRectanglesView.rectangles = rects
            }
        }
        try! imageRequestHandler.perform([request])
    }
}
//        // CoreMLのモデルクラスの初期化
//        guard let model = try? VNCoreMLModel(for: Resnet50().model) else {
//            assertionFailure("Error: CoreMLモデルの初期化に失敗しました")
//            return
//        }
//
//        // 画像認識リクエストを作成（引数はモデルとハンドラ）
//        let request = VNCoreMLRequest(model: model) { [weak self] (request: VNRequest, error: Error?) in
//            guard let results = request.results as? [VNClassificationObservation] else { return }
//
//            // 判別結果とその確信度を上位3件まで表示
//            // identifierは類義語がカンマ区切りで複数書かれていることがあるので、最初の単語のみ取得する
//            let displayText = results.prefix(3).compactMap { "\(Int($0.confidence * 100))% \($0.identifier.components(separatedBy: ", ")[0])" }.joined(separator: "\n")
//
//            DispatchQueue.main.async {
//                self?.textView.text = displayText
//            }
//        }
//
//        // CVPixelBufferに対し、画像認識リクエストを実行
//        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
