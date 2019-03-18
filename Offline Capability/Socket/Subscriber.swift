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

class Subscriber: NSObject {
    var tag: Int = 0
    var socket: GCDAsyncSocket!
    var proxy: RxGCDAsyncSocketDelegateProxy!
    let disposeBag = DisposeBag()
    
    override init() {
        super.init()
    }
    
    func setupSocket() {
        socket = GCDAsyncSocket()
        proxy = RxGCDAsyncSocketDelegateProxy(socket: socket)
        socket.delegate = proxy
        socket.delegateQueue = DispatchQueue.main
    }
    
    func subscribe(topic: String) {
        socket.rx.connected
            .subscribe(onNext: { [weak self] in
                if($0) {
                    var send = "Resubscribe,\(topic),^@\r"
                    if self?.tag == 0 {
                        send = "Subscribe,\(topic),^@\r"
                    }
                    self?.tag += 1
                    self?.socket?.write(send.data(using: String.Encoding.utf8)!, withTimeout: 60, tag: self?.tag ?? 0)
                }
            })
            .disposed(by: disposeBag)
        
        socket.rx.didWrite
            .subscribe(onNext: { [weak self] in
                if($0) {
                    self?.tag += 1
                    self?.socket?.readData(withTimeout: 3600, tag: self?.tag ?? 0)
                }
            })
            .disposed(by: disposeBag)
        
        socket.rx.message
            .subscribe(onNext: { [weak self] in
                if($0.contains("^@\r")) {
                    self?.tag += 1
                    let send = "Unsubscribe,\(topic),^@\r"
                    self?.tag += 1
                    self?.socket?.write(send.data(using: String.Encoding.utf8)!, withTimeout: 60, tag: self?.tag ?? 0)
                    self?.socket.disconnectAfterReadingAndWriting()
                }
            })
            .disposed(by: disposeBag)
        
        do { try socket.connect(toHost: SocketConstants.SERVER_IP, onPort: UInt16(SocketConstants.SUBSCRIBER_PORT)) } catch { print("connect not working") }
    }
}
