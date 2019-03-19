
import Foundation

/** generic queue with thread safety
 */
class Queue<T> {
    var list = [T]()
    let dispatchQueue = DispatchQueue(label: "Queue", attributes: .concurrent)
    
    /** enqueues an element
     */
    func enqueue(_ element: T) {
        dispatchQueue.async(flags: .barrier) {
            self.list.append((element))
        }
    }
    
    /** dequeues an element
     - Returns: the element
     */
    func dequeue() -> T? {
        var result: T?
        dispatchQueue.sync {
            guard !self.list.isEmpty else { return }
            result = self.list.removeFirst();
        }
        
        return result
    }
    
    /** peeks an element without dequeueing
     - Returns: the element
     */
    func peek() -> T? {
        var result: T?
        dispatchQueue.sync {
            guard !self.list.isEmpty else { return }
            result = list[0]
        }
        
        return result
    }
}
