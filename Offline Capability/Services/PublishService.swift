//
//  PublishService.swift
//  Offline Capability
//
//  Created by Simon Angerbauer on 27.02.19.
//  Copyright © 2019 Simon Angerbauer. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift

/** Service that publishes the elements from the queue via sockets to the server
 */
class PublishService {
    /** reachability service */
    let reachabilityService: ReachabilityService
    /** publisher socket */
    let publisher: Publisher
    /** queue to publish */
    var queue = Queue<(topic: String, data: String, state: State)>()
    /** dispose bag needed for rx */
    let disposeBag = DisposeBag()
    /** tracker if queue is worked on or not */
    var started = false
    
    /** initializes the service */
    init(publisherSocket: Publisher, reachability: ReachabilityService) {
        reachabilityService = reachability
        publisher = publisherSocket
    }
    
    /** observes the socket for new events.
     Queue working is started accordingly
     */
    func observeSocket() {
        DispatchQueue.main.async {
            self.publisher.socket.rx.writeDidTimeOut.subscribe(onNext: { value in
                if value {
                    self.started = false
                    self.start()
                }
            }).disposed(by: self.disposeBag)
            
            self.publisher.socket.rx.disconnected.subscribe(onNext: { error in
                self.started = false
                self.start()
            }).disposed(by: self.disposeBag)
        }
    }
    
    /** starts working on the queue if connectivity allows it */
    func start(){
        reachabilityService.reachability
            .subscribe { [weak self] event in
                if event.element?.reachable ?? false {
                    if !(self?.started ?? true) {
                        self?.started = true
                        self?.work()
                    }
                } else {
                    self?.started = false
                }
            }
            .disposed(by: disposeBag)
    }
    
    /** works the queue by removing items and publishing them via socket */
    private func work() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let `self` = self else { return }
            if self.started {
                if let item = self.queue.dequeue()
                {
                    let message = "{data:\(item.data), topic:\"\(item.topic)\", state:\(item.state.rawValue)}^@\r"
                    
                    self.publisher.socket?.disconnectAfterReadingAndWriting()
                    DispatchQueue.main.sync {
                        self.publisher.setupSocket()
                        self.observeSocket()
                    }
                    self.publisher.publish(message: message)
                    self.work()
                }
                else {
                    sleep(1)
                    self.work()
                }
            }
        }
    }
    
    /** resolves a thread safe reference of a realm object */
    private func resolve(reference: ThreadSafeReference<RealmTask>) -> RealmTask? {
        let realm = try! Realm()
        if let resolved = realm.resolve(reference) {
            return resolved
        }
        
        return nil
    }
}
