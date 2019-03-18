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
    var tag: Int = 0
    var socket: GCDAsyncSocket!
    var proxy: RxGCDAsyncSocketDelegateProxy!
    let disposeBag = DisposeBag()
    var connected = Variable<Bool>(false)
    
    override init() {
        super.init()
    }
    
    func setupSocket() {
        self.socket = GCDAsyncSocket()
        self.proxy = RxGCDAsyncSocketDelegateProxy(socket: self.socket)
        self.socket.delegate = self.proxy
        self.socket.delegateQueue = DispatchQueue.main
        
        self.socket.rx.connected
            .bind(to: self.connected)
            .disposed(by: self.disposeBag)
        
        self.socket.rx.disconnected
            .subscribe { [weak self] _ in
                self?.connected = Variable(false)
            }
            .disposed(by: self.disposeBag)
        
        do { try socket.connect(toHost: SocketConstants.SERVER_IP, onPort: UInt16(SocketConstants.PUBLISHER_PORT)) } catch { print("connect not working") }
    }
    
    func publish(message: String) {
        tag += 1
        self.socket.write(message.data(using: String.Encoding.utf8)!, withTimeout: 60, tag: tag)
    }
}
