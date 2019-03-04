import Foundation
import CocoaAsyncSocket
import RxSwift
import RxCocoa

public enum SocketResponse {
    case didConnect
    case didReadText(String)
    case didWrite
    case didDisconnect(Error?)
}

public class RxGCDAsyncSocketDelegateProxy: DelegateProxy<GCDAsyncSocket, GCDAsyncSocketDelegate>, GCDAsyncSocketDelegate, DelegateProxyType {
    fileprivate let connected = PublishSubject<Bool>()
    fileprivate let message = PublishSubject<String>()
    fileprivate let disconnected = PublishSubject<Error?>()
    fileprivate let didWrite = PublishSubject<Bool>()
    fileprivate let writeDidTimeOut = PublishSubject<Bool>()
    
    required public init(socket: GCDAsyncSocket) {
        super.init(parentObject: socket, delegateProxy: RxGCDAsyncSocketDelegateProxy.self)
    }
    
    public static func registerKnownImplementations() {
        self.register { RxGCDAsyncSocketDelegateProxy(socket: $0) }
    }
    
    public static func currentDelegate(for object: GCDAsyncSocket) -> GCDAsyncSocketDelegate? {
        return object.delegate
    }
    
    public static func setCurrentDelegate(_ delegate: GCDAsyncSocketDelegate?, to object: GCDAsyncSocket) {
        object.delegate = delegate
    }
    
    public func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        connected.onNext(true)
    }
    
    public func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        disconnected.onNext(err)
    }
    
    public func socket(_ sock: GCDAsyncSocket, shouldTimeoutWriteWithTag tag: Int, elapsed: TimeInterval, bytesDone length: UInt) -> TimeInterval {
        writeDidTimeOut.onNext(true)
        return 0
    }
    
    public func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        didWrite.onNext(true)
    }
    
    public func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        if let msg = String(data: data, encoding: String.Encoding.ascii) {
            message.onNext(msg)
        }
    }
    
    deinit {
        connected.onCompleted()
        message.onCompleted()
        disconnected.onCompleted()
        didWrite.onCompleted()
        writeDidTimeOut.onCompleted()
    }
}

extension Reactive where Base: GCDAsyncSocket {
    public var connected: Observable<Bool> {
        return RxGCDAsyncSocketDelegateProxy.proxy(for: base).connected
    }
    
    public var message: Observable<String> {
        return RxGCDAsyncSocketDelegateProxy.proxy(for: base).message
    }
    
    public var disconnected: Observable<Error?> {
        return RxGCDAsyncSocketDelegateProxy.proxy(for: base).disconnected
    }
    
    public var didWrite: Observable<Bool> {
        return RxGCDAsyncSocketDelegateProxy.proxy(for: base).didWrite
    }
    
    public var writeDidTimeOut: Observable<Bool> {
        return RxGCDAsyncSocketDelegateProxy.proxy(for: base).writeDidTimeOut
    }
}
