import Foundation
import CocoaAsyncSocket
import RxSwift
import RxCocoa

public enum SocketResponse {
    case didConnect
    case didReadText(String)
    case didDisconnect(Error?)
}

public class RxGCDAsyncSocketDelegateProxy: DelegateProxy<GCDAsyncSocket, GCDAsyncSocketDelegate>, GCDAsyncSocketDelegate, DelegateProxyType {
    fileprivate let subject = PublishSubject<SocketResponse>()
    
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
        subject.onNext(.didConnect)
    }
    
    public func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        subject.onNext(.didDisconnect(err))
    }
    
    public func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        if let message = String(data: data, encoding: String.Encoding.ascii) {
            subject.onNext(.didReadText(message))
        }
    }
    
    deinit {
        subject.onCompleted()
    }
}

extension Reactive where Base: GCDAsyncSocket {
    public var response: Observable<SocketResponse> {
        return RxGCDAsyncSocketDelegateProxy.proxy(for: base).subject
    }
    
    public var connected: Observable<Bool> {
        //TODO: check why only called on disconnect, not on connect
        return response.flatMap { (response) -> Observable<Bool> in
            switch response {
            case .didConnect:
                return Observable.just(true)
            default:
                return Observable.just(false)
            }
        }
    }
}
