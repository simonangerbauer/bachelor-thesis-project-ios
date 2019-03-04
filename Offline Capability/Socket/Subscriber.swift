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
    var socket: GCDAsyncSocket!
    var proxy: RxGCDAsyncSocketDelegateProxy!
    let disposeBag = DisposeBag()
    
    override init() {
        super.init()
    }
    
    func subscribe(topic: String) {
        socket = GCDAsyncSocket()
        proxy = RxGCDAsyncSocketDelegateProxy(socket: socket)
        socket.delegate = proxy
        socket.delegateQueue = DispatchQueue.main
        socket.rx.connected
            .subscribe(onNext: { [weak self] in
                if($0) {
                    let send = "Subscribe,\(topic),^@"
                    self?.socket?.write(send.data(using: String.Encoding.utf8)!, withTimeout: 60, tag: 1)
                }
            })
            .disposed(by: disposeBag)
        
        socket.rx.didWrite
            .subscribe(onNext: { [weak self] in
                if($0) {
                    self?.socket?.readData(withTimeout: 3600, tag: 2)
                }
            })
            .disposed(by: disposeBag)
        
        socket.rx.message
            .subscribe(onNext: { [weak self] in
                if($0.contains("^@")) {
                    self?.socket?.readData(withTimeout: 3600, tag: 2)
                }
            })
            .disposed(by: disposeBag)
        
        do { try socket.connect(toHost: SocketConstants.SERVER_IP, onPort: UInt16(SocketConstants.SUBSCRIBER_PORT)) } catch { print("connect not working") }
    }
}
