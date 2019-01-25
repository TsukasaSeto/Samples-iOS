// Copyright (c) 2018 Ricoh IT Solutions Co.,Ltd. All rights reserved.

import UIKit
import AVFoundation

class PreviewView: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    /// Convenience wrapper to get layer as its statically known type.
    var videoPreviewLayer: AVCaptureVideoPreviewLayer? {
        return layer as? AVCaptureVideoPreviewLayer
    }
}

class BuiltInCameraCaptureViewController: UIViewController {

    let captureView = PreviewView(frame: .zero)
    private let captureSession = AVCaptureSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        configureCaptureSession()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        startCapture()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        let deviceOrientation = UIDevice.current.orientation
        guard deviceOrientation.isPortrait || deviceOrientation.isLandscape else { return }
        guard let newVideoOrientation = deviceOrientation.videoOrientation else { return }
        captureView.videoPreviewLayer?.connection?.videoOrientation = newVideoOrientation
    }
    
    func startCapture() {
        guard !captureSession.isRunning else { return }
        captureSession.startRunning()
    }
    
    func stopCapture() {
        guard captureSession.isRunning else { return }
        captureSession.stopRunning()
    }
    
    private func configureCaptureSession() {
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
        let statusBarOrientation = UIApplication.shared.statusBarOrientation
        var initialVideoOrientation: AVCaptureVideoOrientation = .portrait
        if statusBarOrientation != .unknown {
            if let videoOrientation = statusBarOrientation.videoOrientation {
                initialVideoOrientation = videoOrientation
            }
        }
        captureView.videoPreviewLayer?.connection!.videoOrientation = initialVideoOrientation
        
        // add output
        let videoDataOutput = AVCaptureVideoDataOutput()
        guard captureSession.canAddOutput(videoDataOutput) else {
            print("Error: Cannot add output.")
            captureSession.commitConfiguration()
            return
        }
        videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as String): Int(kCVPixelFormatType_32BGRA)]
        // videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "video_data_output_queue"))
        videoDataOutput.alwaysDiscardsLateVideoFrames = true
        captureSession.addOutput(videoDataOutput)
        
        captureSession.commitConfiguration()
    }
    
    private func configureView() {
        captureView.frame = view.frame
        captureView.autoresizingMask = [.flexibleWidth, .flexibleHeight, .flexibleTopMargin, .flexibleBottomMargin, .flexibleLeftMargin, .flexibleRightMargin]
        captureView.videoPreviewLayer?.session = captureSession
        view.addSubview(captureView)
    }
    
}

extension UIDeviceOrientation {
    var videoOrientation: AVCaptureVideoOrientation? {
        switch self {
        case .portrait: return .portrait
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeLeft: return .landscapeRight
        case .landscapeRight: return .landscapeLeft
        default: return nil
        }
    }
}

extension UIInterfaceOrientation {
    var videoOrientation: AVCaptureVideoOrientation? {
        switch self {
        case .portrait: return .portrait
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeLeft: return .landscapeLeft
        case .landscapeRight: return .landscapeRight
        default: return nil
        }
    }
}
