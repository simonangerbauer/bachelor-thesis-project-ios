import Foundation
import RealmSwift
import RxSwift
import RxRealm

/** Provides all possible operations of tasks. Communicates with the realm mobile platform */
class TaskService: TaskServiceType {
    
    /** The config used to connect to the realm */
    let config: Realm.Configuration
    let disposeBag = DisposeBag()
    let subscriber: Subscriber
    let publishService: PublishService
    
    /** initializes the realm config and injects subscriber socket */
    init(subscriberSocket: Subscriber, publish: PublishService) {
        subscriber = subscriberSocket
        publishService = publish
        config = Realm.Configuration.defaultConfiguration
    }
    
    private func withRealm<T>(_ operation: String, action: (Realm) throws -> T) -> T? {
        do {
            let realm = try Realm(configuration: config);
            return try action(realm)
        } catch let error {
            print("Failed \(operation) realm with error: \(error)")
            return nil
        }
    }
    
    /** creates a task with all given attributes
     - Returns: Observable of the created task
     */
    @discardableResult
    func createTask(title: String, description: String, due: Date, activity: String, officers: String, proofs: [String]) -> Observable<RealmTask> {
        let result = withRealm("creating") { [weak self] realm -> Observable<RealmTask> in
            let task = RealmTask()
            task.Title = title
            task.Description = description
            task.Due = due
            task.Activity = activity
            task.Progress = 0
            task.Proofs.append(objectsIn: proofs)
            task.Officers = officers
            
            try realm.write {
                task.Id = UUID().uuidString
                realm.add(task)
            }
            
            self?.publishService.queue.enqueue((Topic.Task.rawValue, ThreadSafeReference(to: task)))
            
            return .just(task)
        }
        return result ?? .error(TaskServiceError.creationFailed)
    }
    
    func delete(task: RealmTask) -> Observable<Void> {
        return Observable.empty()
    }
    
    func update(task: RealmTask, name: String, description: String, due: Date, activity: String, progress: Int, officers: [String], revisors: [String], proofs: [String]) -> Observable<RealmTask> {
        return Observable.empty()
    }
    
    func tasks() -> Observable<Changeset<RealmTask>> {
        subscriber.subscribe(topic: Topic.Task.rawValue)
        subscriber.socket.rx.message
            .subscribe(onNext: {
                if($0.contains("^@")) {
                    let json = $0.dropLast(2).data(using: .utf8, allowLossyConversion: false)!
                }
            })
            .disposed(by: disposeBag)
        return Observable.empty()
    }
    
    
    
    /*
    /** creates a task with all given attributes
     - Returns: Observable of the created task
     */
    @discardableResult
    func createTask(name: String, description: String, due: Date, activity: String, officers: [String], revisors: [String], proofs: [String]) -> Observable<RealmTask> {
        let result = withRealm("creating") { realm -> Observable<RealmTask> in
            let task = RealmTask()
            task.name = name
            task.taskDescription = description
            task.due = due
            task.activity = activity
            task.progress = 0
            task.proofs.append(objectsIn: proofs)
            task.revisors.append(objectsIn: revisors)
            task.officers.append(objectsIn: officers)
            
            try realm.write {
                task.uid = UUID().uuidString
                realm.add(task)
            }
            
            return .just(task)
        }
        return result ?? .error(TaskServiceError.creationFailed)
    }
    
    /** updates the given properties of the task
     - Returns: Observable of the updated task
     */
    @discardableResult
    func update(task: RealmTask, name: String, description: String, due: Date, activity: String, progress: Int, officers: [String], revisors: [String], proofs: [String]) -> Observable<RealmTask> {
        let result = withRealm("updating") { realm -> Observable<RealmTask> in
            try realm.write {
                task.name = name
                task.taskDescription = description
                task.due = due
                task.activity = activity
                task.progress = progress
                task.officers.removeAll()
                task.officers.append(objectsIn: officers)
                task.revisors.removeAll()
                task.revisors.append(objectsIn: revisors)
                task.proofs.removeAll()
                task.proofs.append(objectsIn: proofs)
            }
            
            return .just(task)
        }
        return result ?? .error(TaskServiceError.updateFailed(task))
    }
    
    /** deletes the given task
     - Returns: An empty observable
     */
    func delete(task: RealmTask) -> Observable<Void> {
        let result = withRealm("deleting") { realm -> Observable<Void> in
            try realm.write {
                realm.delete(task)
            }
            return .empty()
        }
        return result ?? .error(TaskServiceError.deletionFailed(task))
    }
    
    /** Gets all the tasks
     - Returns: Observable of the realm collection With live updates as changesets
     */
    func tasks() -> Observable<(AnyRealmCollection<RealmTask>, RealmChangeset?)> {
        let result = withRealm("getting tasks") { realm -> Observable<(AnyRealmCollection<RealmTask>, RealmChangeset?)> in
            let tasks = realm.objects(RealmTask.self)
            return Observable.changeset(from: tasks)
        }
        
        return result ?? .empty()
    }*/
}