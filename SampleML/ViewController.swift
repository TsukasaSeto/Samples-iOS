//
//  ViewController.swift
//  SampleML
//
//  Created by Tsukasa Seto on 2018/05/01.
//  Copyright © 2018年 Tsukasa Seto. All rights reserved.
//

import UIKit
import CoreML
import Vision
import AVFoundation


class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var photoDisplay: UIImageView!
    @IBOutlet weak var photoInfoDisplay: UITextView!

    var imagePicker: UIImagePickerController?

    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker = UIImagePickerController()
        imagePicker?.delegate = self
        imagePicker?.sourceType = .camera
    }

    @IBAction func takePhoto(_ sender: Any) {
        guard let imgPicker = imagePicker else { return }
        present(imgPicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            photoDisplay.image = image
            imageInference(image: image)
        }
        imagePicker?.dismiss(animated: true, completion: nil)
    }

    func imageInference(image: UIImage) {
//      guard let model = try? VNCoreMLModel(for: Resnet50().model) else {
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            fatalError("モデルをロードできません")
        }

        let request = VNCoreMLRequest(model: model) { [weak self] (request, error) in
            guard let results = request.results as? [VNClassificationObservation], let firstResult = results.first else {
                fatalError("判定できません")
            }

            DispatchQueue.main.async {
                self?.photoInfoDisplay.text = "Accuracy:  = \(Int(firstResult.confidence * 100))% \n\nText Label: \((firstResult.identifier))"
                let utterWords = AVSpeechUtterance(string: (self?.photoInfoDisplay.text)!)
                utterWords.voice = AVSpeechSynthesisVoice(language: "en-US")
                let synthesizer = AVSpeechSynthesizer()
                synthesizer.speak(utterWords)
            }
        }

        guard let ciImage = CIImage(image: image) else {
            fatalError("画像を変換できません")
        }
        let imageHandler = VNImageRequestHandler(ciImage: ciImage)

        DispatchQueue.global(qos: .userInteractive).async {
            do {
                try imageHandler.perform([request])
            } catch {
                print("エラー \(error)")
            }
        }
    }

}
