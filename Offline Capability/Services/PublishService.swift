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

class PublishService {
    let reachabilityService: ReachabilityService
    let publisher: Publisher
    var queue = Queue<(topic: String, entity: ThreadSafeReference<RealmTask>)>()
    let disposeBag = DisposeBag()
    var started = false
    
    init(publisherSocket: Publisher, reachability: ReachabilityService) {
        reachabilityService = reachability
        publisher = publisherSocket
        
    }
    
    func start(){
        reachabilityService.reachability
            .subscribe { [weak self] event in
                if event.element?.reachable ?? false {
                    if !(self?.started ?? true) {
                        self?.started = true
                        self?.work()
                    }
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func work() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let `self` = self else { return }
            if let item = self.queue.peek(),
                let entity = self.resolve(reference: item.entity),
                let data = try? String(data: JSONEncoder().encode(entity), encoding: .utf8)
            {
                let message = "{data:\(data!), topic:\"\(item.topic)\"}^@"
                self.publisher.publish(message: message)
                
                DispatchQueue.main.async {
                    self.publisher.socket.rx.didWrite.subscribe(onNext: { value in
                        if value {
                            _ = self.queue.dequeue()
                            self.work()
                        }
                    }).disposed(by: self.disposeBag)
                    
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
            else {
                sleep(1)
                self.work()
            }
        }
    }
    
    private func resolve(reference: ThreadSafeReference<RealmTask>) -> RealmTask? {
        let realm = try! Realm()
        if let resolved = realm.resolve(reference) {
            return resolved
        }
        
        return nil
    }
}
