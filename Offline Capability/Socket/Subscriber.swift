
import UIKit
import RxSwift
import RxCocoa
import CocoaAsyncSocket

/** Subscriber Socket that interacts with the SubsriberService on the Server */
class Subscriber: NSObject {
    /** a tag that is increased for each socket operation */
    var tag: Int = 0
    /** the socket to communicate on */
    var socket: GCDAsyncSocket!
    /** the reactive proxy that implements all delegate methods */
    var proxy: RxGCDAsyncSocketDelegateProxy!
    /** to dispose reactive disposables */
    let disposeBag = DisposeBag()
    
    override init() {
        super.init()
    }
    
    /** sets up the socket */
    func setupSocket() {
        socket = GCDAsyncSocket()
        proxy = RxGCDAsyncSocketDelegateProxy(socket: socket)
        socket.delegate = proxy
        socket.delegateQueue = DispatchQueue.main
    }
    
    /** subscribes this socket to the server for a topic */
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
