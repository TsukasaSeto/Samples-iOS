//
//  SettingViewController.swift
//  SampleTimer
//
//  Created by Tsukasa Seto on 2018/04/25.
//  Copyright © 2018年 Tsukasa Seto. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    let valueArray: [Int] = [10, 30, 60, 120, 180]
    let settingKey = "timerValue"

    @IBOutlet weak var timerPicker: UIPickerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        timerPicker.delegate = self
        timerPicker.dataSource = self

        let timerValue = UserDefaults.standard.integer(forKey: settingKey)

        for row in 0..<valueArray.count {
            if valueArray[row] == timerValue {
                timerPicker.selectRow(row, inComponent: 0, animated: true)
            }
        }
    }

    @IBAction func chooseAction(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return valueArray.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(valueArray[row])
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        UserDefaults.standard.set(valueArray[row], forKey: settingKey)
        UserDefaults.standard.synchronize()
    }

}
