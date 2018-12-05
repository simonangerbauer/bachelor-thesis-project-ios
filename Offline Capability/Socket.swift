//
//  Socket.swift
//  Offline Capability
//
//  Created by Simon Angerbauer on 05.12.18.
//  Copyright © 2018 Simon Angerbauer. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class PubSubClient: NSObject, GCDAsyncUdpSocketDelegate {
    let IP = "127.0.0.1"
    let PORT = 5001
    var socket: GCDAsyncUdpSocket!
    
    override init() {
        super.init()
        setupConnection()
    }
    
    func setupConnection() {
        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        do { try socket.bind(toPort: PORT)} catch { print("")}
        do { try socket.enableBroadcast(true)} catch { print("not able to brad cast")}
        do { try socket.joinMulticastGroup(IP)} catch { print("joinMulticastGroup not procceed")}
        do { try socket.beginReceiving()} catch { print("beginReceiving not procceed")}
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        print("incoming message: \(data)");
        let signal: Signal = Signal.unarchive(d: data)
        print("signal information : \n first \(signal.firstSignal) , second \(signal.secondSignal) \n third \(signal.thirdSignal) , fourth \(signal.fourthSignal)")
    }
}
