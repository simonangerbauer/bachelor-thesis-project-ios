//
//  Socket.swift
//  Offline Capability
//
//  Created by Simon Angerbauer on 05.12.18.
//  Copyright © 2018 Simon Angerbauer. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

class ReceivingSocket: NSObject, GCDAsyncUdpSocketDelegate {
    let IP = "127.0.0.1"
    let SERVER_PORT = 10001
    let CLIENT_PORT = 5001
    var socket: GCDAsyncUdpSocket!
    
    override init() {
        super.init()
        setupConnection()
    }
    
    func setupConnection() {
        socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
        do { try socket.bind(toPort: UInt16(CLIENT_PORT)) } catch { print("bind not working") }
        let message = "Subscribe,topic,datalul"
        socket.send(message.data(using: .ascii)!, toHost: IP, port: UInt16(SERVER_PORT), withTimeout: 5.0, tag: 1)
        //do { try socket.enableBroadcast(true)} catch { print("not able to brad cast")}
        //do { try socket.joinMulticastGroup(IP)} catch { print("joinMulticastGroup not procceed")}
        do { try socket.beginReceiving()} catch { print("beginReceiving not working") }
        
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        print("incoming message: \(data)");
    }
}
