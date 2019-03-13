//
//  Queue.swift
//  Offline Capability
//
//  Created by Simon Angerbauer on 27.02.19.
//  Copyright © 2019 Simon Angerbauer. All rights reserved.
//

import Foundation

class Queue<T> {
    var list = [T]()
    let dispatchQueue = DispatchQueue(label: "Queue", attributes: .concurrent)
    
    func enqueue(_ element: T) {
        dispatchQueue.async(flags: .barrier) {
            self.list.append(element)
        }
    }
    
    func dequeue() -> T? {
        var result: T?
        dispatchQueue.sync {
            guard !self.list.isEmpty else { return }
            result = self.list.removeFirst();
        }
        
        return result
    }
    
    func peek() -> T? {
        var result: T?
        dispatchQueue.sync {
            guard !self.list.isEmpty else { return }
            result = list[0]
        }
        
        return result
    }
}
