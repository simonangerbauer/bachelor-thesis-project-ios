//
//  ViewController.swift
//  Offline Capability
//
//  Created by Simon Angerbauer on 04.09.18.
//  Copyright © 2018 Simon Angerbauer. All rights reserved.
//

import UIKit
import SwiftGRPC

class ViewController: UIViewController {

    @IBOutlet weak var textField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            let client = Helloworld_GreeterServiceClient.init(address: "127.0.0.1:50051", secure: false)
            do {
                var request = Helloworld_HelloRequest()
                request.name = "simon"
                self.textField.text = try client.sayHello(request).message
//                let test = try client.sayHello(request, completion: {[weak self] (reply, result) in
//                    self?.displayMessageReceived(reply?.message)
//                })
            } catch {
                print("unexpected error!")
            }
        }
        // Do any additional setup after loading the view, typically from a nib.
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

