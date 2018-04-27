//
//  ViewController.swift
//  SampleNFC
//
//  Created by Tsukasa Seto on 2018/04/27.
//  Copyright © 2018年 Tsukasa Seto. All rights reserved.
//

import UIKit
import CoreNFC

class ViewController: UIViewController, NFCNDEFReaderSessionDelegate {

    @IBOutlet weak var resultText: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func startReadNFC(_ sender: Any) {
        let session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        session.begin()
        print("セッションがスタートしました")
    }

    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        print("エラーが発生しました")
    }

    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        for message in messages {
            for record in message.records {
                // payloadの先頭に2文字分無駄な文字が入っているので、advancedでスキップする
                if let payloadString = String(data: record.payload.advanced(by: 1), encoding: .utf8) {
                    print(payloadString)
                    DispatchQueue.main.async {
                        self.resultText.text = payloadString
                    }
                }
            }
        }
    }

}
