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

/** The publisher socket that communicates with the PublisherService on the Server */
class Publisher: NSObject {
    /** a tag that is increased for each socket operation */
    var tag: Int = 0
    /** the socket to communicate on */
    var socket: GCDAsyncSocket!
    /** the reactive proxy that implements all delegate methods */
    var proxy: RxGCDAsyncSocketDelegateProxy!
    /** to dispose reactive disposables */
    let disposeBag = DisposeBag()
    /** a variable that indicates if socket is connected or not */
    var connected = Variable<Bool>(false)
    
    override init() {
        super.init()
    }
    
    /** sets up the socket */
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
    
    /** publishes a message to the server */
    func publish(message: String) {
        tag += 1
        self.socket.write(message.data(using: String.Encoding.utf8)!, withTimeout: 60, tag: tag)
    }
}
