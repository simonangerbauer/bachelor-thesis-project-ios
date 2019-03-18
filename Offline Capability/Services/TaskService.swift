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
    let tasksSubject = PublishSubject<Changeset<RealmTask>>()
    var changeset = Changeset<RealmTask>(results: [RealmTask](), deleted: [Int](), inserted: [Int](), updated: [Int]())
    
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
                task.Id = UUID().uuidString.lowercased()
                realm.add(task)
            }
            
            changeset.results.append(task)
            tasksSubject.onNext(changeset)
            if let data = encodeTask(task) {
                self?.publishService.queue.enqueue((Topic.Task.rawValue, data, State.Added))
            }
            return .just(task)
        }
        return result ?? .error(TaskServiceError.creationFailed)
    }
    
    func delete(task: RealmTask) -> Observable<Void> {
        if let data = encodeTask(task) {
            publishService.queue.enqueue((Topic.Task.rawValue, data, State.Deleted))
        }
        
        self.withRealm("deleting") { realm in
            //let dbTask = realm.object(ofType: RealmTask.self, forPrimaryKey: task.Id)
            try realm.write {
                realm.delete(task)
            }
        }
        
        if let index = changeset.results.firstIndex(of: task) {
            changeset.results.remove(at: index)
        }
        
        tasksSubject.onNext(changeset)
        
        return Observable.empty()
    }
    
    func update(task: RealmTask) -> Observable<RealmTask> {
        self.withRealm("deleting") { realm in
            try realm.write {
                realm.add(task, update: true)
            }
        }
        
        let oldTask = changeset.results.first(where: { $0.Id.lowercased() == task.Id.lowercased()})!
        changeset.results.remove(at: changeset.results.firstIndex(of: oldTask)!)
        changeset.results.append(task)
        tasksSubject.onNext(changeset)
        if let data = encodeTask(task) {
            publishService.queue.enqueue((Topic.Task.rawValue, data, State.Modified))
        }
        return Observable.just(task)
    }
    
    func getTasks() {
        
        changeset = self.withRealm("getting tasks") { realm -> Changeset<RealmTask> in
            try realm.write {
                realm.deleteAll()
            }
            let tasks = realm.objects(RealmTask.self)
            return Changeset<RealmTask>(results: tasks.toArray(), deleted: [Int](), inserted: [Int](), updated: [Int]())
            }!
        
        tasksSubject.onNext(changeset)
        
        self.subscriber.setupSocket()
        observeSocket()
        self.subscriber.subscribe(topic: Topic.Task.rawValue)
    }
    
    func observeSocket() {
        self.subscriber.socket.rx.message.subscribe(onNext: { [weak self] value in
            guard let `self` = self else { return }
            do
            {
                let json: Data = value.dropLast(3).data(using: .utf8, allowLossyConversion: false)!
                let jsonData = try JSONDecoder().decode(JsonData.self, from: json)
                let task = jsonData.data
                let isInDb = self.changeset.results.contains(where: { $0.Id.lowercased() == task.Id.lowercased()})
                if !isInDb {
                    self.withRealm("creating") { realm in
                        try realm.write {
                            realm.add(task)
                        }
                    }
                    self.changeset.results.append(task)
                }
                else if jsonData.state == 3 {
                    let taskInDb = self.changeset.results.first(where: { $0.Id.lowercased() == task.Id.lowercased()})!
                    self.withRealm("deleting") { realm in
                        try realm.write {
                            realm.delete(taskInDb)
                        }
                    }
                    self.changeset.results.remove(at: self.changeset.results.firstIndex(of: taskInDb)!)
                }
                else {
                    let taskInDb = self.changeset.results.first(where: { $0.Id.lowercased() == task.Id.lowercased()})!
                    self.withRealm("modifying") { realm in
                        try realm.write {
                            realm.delete(taskInDb)
                        }
                        try realm.write {
                            realm.add(task)
                        }
                    }
                    self.changeset.results.remove(at: self.changeset.results.firstIndex(of: taskInDb)!)
                    self.changeset.results.append(task)
                }
                self.tasksSubject.onNext(self.changeset)
                
                DispatchQueue.main.async {
                    self.subscriber.setupSocket()
                    self.observeSocket()
                    self.subscriber.subscribe(topic: Topic.Task.rawValue)
                }
            }
            catch let error {
                print(error.localizedDescription)
            }
        })
            .disposed(by: self.disposeBag)
    }
    
    func encodeTask (_ task: RealmTask) -> String? {
        return try! String(data: JSONEncoder().encode(task), encoding: .utf8)
    }
}
