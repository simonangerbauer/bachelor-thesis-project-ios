//
//  ViewController.swift
//  Offline Capability
//
//  Created by Simon Angerbauer on 04.09.18.
//  Copyright © 2018 Simon Angerbauer. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    let socket = ReceivingSocket()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func displayMessageReceived(_ message: String?) {
        DispatchQueue.main.async {
            self.textField.text = message
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

