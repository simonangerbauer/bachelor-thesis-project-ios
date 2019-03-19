
import Foundation
import RxSwift
import RxRealm
import RealmSwift

/** Possible Errors that can be thrown by the task service */
enum TaskServiceError: Error {
    case creationFailed
    case updateFailed(RealmTask)
    case deletionFailed(RealmTask)
}

/** Protocol the task service needs to conform to. Contains all possible operations on tasks */
protocol TaskServiceType {
    var tasksSubject: PublishSubject<Changeset<RealmTask>> { get }
    
    /** creates a task with all given attributes
     - Returns: Observable of the created task
     */
    @discardableResult
    func createTask(title: String, description: String, due: Date, activity: String, officers: String, proofs: [String]) -> Observable<RealmTask>
    
    /** deletes the given task
     - Returns: An empty observable
     */
    @discardableResult
    func delete(task: RealmTask) -> Observable<Void>
    
    /** updates the given properties of the task
     - Returns: Observable of the updated task
     */
    @discardableResult
    func update(task: RealmTask, name: String, description: String, due: Date, activity: String, progress: Int) -> Observable<RealmTask>
    
    /** Gets all the tasks
     - Returns: Observable of tasks
     */
    func getTasks()
}
