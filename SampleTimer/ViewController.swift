//
//  ViewController.swift
//  SampleTimer
//
//  Created by Tsukasa Seto on 2018/04/25.
//  Copyright © 2018年 Tsukasa Seto. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var timer: Timer?
    var duration = 0
    let settingKey = "timerValue"

    @IBOutlet weak var timeLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.register(defaults: [settingKey: 60])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        duration = 0
        _ = displayUpdate()
    }

    @IBAction func settingButtonAction(_ sender: Any) {
        if let nowTimer = timer, nowTimer.isValid {
            nowTimer.invalidate()
        }
        performSegue(withIdentifier: "openSetting", sender: nil)
    }

    @IBAction func startTimerAction(_ sender: Any) {
        if let nowTimer = timer, nowTimer.isValid { return }

        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.timerStop(_:)), userInfo: nil, repeats: true)
    }

    @IBAction func stopTimerAction(_ sender: Any) {
        if let nowTimer = timer, nowTimer.isValid {
            nowTimer.invalidate()
        }
    }

    func displayUpdate() -> Int {
        let timerValue = UserDefaults.standard.integer(forKey: settingKey)
        let remainSeconds = timerValue - duration

        timeLabel.text = "あと\(remainSeconds)秒"
        return remainSeconds
    }

    @objc func timerStop(_ timer: Timer) {
        duration += 1
        if displayUpdate() <= 0 {
            duration = 0
            timer.invalidate()
        }
    }

}
