//
//  ViewController.swift
//  SampleCamera
//
//  Created by Tsukasa Seto on 2018/04/24.
//  Copyright © 2018年 Tsukasa Seto. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var photoImage: UIImageView!


    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func cameraLaunchAction(_ sender: Any) {
        guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
            print("Camera is not available.")
            return
        }

        print("Camera can be used.")
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.delegate = self
        present(imagePickerController, animated:true, completion: nil)
    }

    @IBAction func shareAction(_ sender: Any) {
        guard let sharedImage = photoImage.image else {
            return
        }
        
        let sharedItems = [sharedImage]
        let controller = UIActivityViewController(activityItems: sharedItems, applicationActivities: nil)
        controller.popoverPresentationController?.sourceView = view
        present(controller, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        photoImage.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        dismiss(animated: true, completion: nil)
    }

}
