//
//  Socket.swift
//  Offline Capability
//
//  Created by Simon Angerbauer on 05.12.18.
//  Copyright © 2018 Simon Angerbauer. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import CocoaAsyncSocket

class ReceivingSocket: NSObject {
    let IP = "127.0.0.1"
    let SERVER_PORT = 10001
    let CLIENT_PORT = 5001
    var socket: GCDAsyncSocket!
    var proxy: RxGCDAsyncSocketDelegateProxy!
    var message = ""
    let disposeBag = DisposeBag()
    
    override init() {
        super.init()
        setupConnection()
    }
    
    func setupConnection() {
        socket = GCDAsyncSocket()
        proxy = RxGCDAsyncSocketDelegateProxy(socket: socket)
        socket.delegate = proxy
        socket.delegateQueue = DispatchQueue.main
        do { try socket.connect(toHost: IP, onPort: UInt16(SERVER_PORT)) } catch { print("connect not workign") }
        socket.rx.connected
            .subscribe(onNext: { [weak self] connected in
                guard let `self` = self else {
                    return
                }
                
                print(connected)
                self.socket.readData(withTimeout: 3600, tag: 2)
            })
            .disposed(by: disposeBag)
    }
//
//    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
//        print(err?.localizedDescription);
//    }
//
//    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
//        let message = "Subscribe,topic,^@"
//        let data = message.data(using: String.Encoding.ascii)!
//        sock.write(data, withTimeout: 5.0, tag: 1)
//    }
//
//    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
//        sock.readData(withTimeout: 3600, tag: 2)
//    }
//
//    func socket(_ sock: GCDAsyncSocket, didReadPartialDataOfLength partialLength: UInt, tag: Int) {
//        var result = "test"
//    }
//
//    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
//        guard let received = String(bytes: data, encoding: String.Encoding.ascii) else {
//            return
//        }
//
//        message.append(contentsOf: received)
//
//        if received.contains("^@") {
//            sock.readData(withTimeout: 3600, tag: 2)
//        }
//
//    }
}
