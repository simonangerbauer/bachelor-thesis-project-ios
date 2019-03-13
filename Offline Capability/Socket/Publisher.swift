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

class Publisher: NSObject {
    var socket: GCDAsyncSocket!
    var proxy: RxGCDAsyncSocketDelegateProxy!
    let disposeBag = DisposeBag()
    var connected = Variable<Bool>(false)
    
    override init() {
        super.init()
        setupSocket()
    }
    
    func setupSocket() {
        socket = GCDAsyncSocket()
        proxy = RxGCDAsyncSocketDelegateProxy(socket: socket)
        socket.delegate = proxy
        socket.delegateQueue = DispatchQueue.main
        socket.rx.connected
            .bind(to: connected)
            .disposed(by: disposeBag)
        
        socket.rx.disconnected
            .subscribe { [weak self] _ in
                self?.connected = Variable(false)
            }
            .disposed(by: disposeBag)  
    }
    
    func reconnect() {
        if(!connected.value) {
            do { try socket.connect(toHost: SocketConstants.SERVER_IP, onPort: UInt16(SocketConstants.PUBLISHER_PORT)) } catch { print("connect not working") }
        }
    }
    
    func publish(message: String) {
        reconnect()
        self.socket.write(message.data(using: String.Encoding.utf8)!, withTimeout: 10, tag: 1)
    }
}
