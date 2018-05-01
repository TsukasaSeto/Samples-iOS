//
//  ViewController.swift
//  SampleMap
//
//  Created by Tsukasa Seto on 2018/04/24.
//  Copyright © 2018年 Tsukasa Seto. All rights reserved.
//

import UIKit
import MapKit


class ViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var inputText: UITextField!
    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        inputText.delegate = self
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()

        guard let searchKeyword = textField.text else { return true }
        print(searchKeyword)

        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(searchKeyword, completionHandler: { (placemarks: [CLPlacemark]?, error: Error?) in
            if let placemark = placemarks?[0] {
                if let targetCoordinate = placemark.location?.coordinate {
                    print(targetCoordinate)

                    let pin = MKPointAnnotation()
                    pin.coordinate = targetCoordinate
                    pin.title = searchKeyword

                    self.mapView.addAnnotation(pin)
                    self.mapView.region = MKCoordinateRegionMakeWithDistance(targetCoordinate, 500.0, 500.0)
                }
            }
        })

        return true
    }

}

