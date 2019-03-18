import Foundation
import RxSwift
import Action

/** Provides business logic for the EditTask View */
struct EditTaskViewModel {
    /** coordinator used for navigation */
    let sceneCoordinator: SceneCoordinatorType
    /** service to handle task requests */
    let taskService: TaskServiceType
    /** the task currently being edited */
    let task: RealmTask
    /** Disposing added observables */
    let disposeBag = DisposeBag()
    
    var isNew = false
    
    /** Initializes the properties and subscribes on Actions to pop view when actions are triggered
     - Parameter coordinator: coordinator to be injected
     - Parameter taskService: service to be injected
     - Parameter task: task being edited */
    init(coordinator: SceneCoordinatorType, taskService: TaskServiceType, task: RealmTask?) {
        self.sceneCoordinator = coordinator
        self.taskService = taskService
        if let sTask = task {
            self.task = sTask
            self.isNew = false
        } else {
            self.task = RealmTask()
            self.isNew = true
        }
        
        onUpdate.executionObservables
            .take(1)
            .subscribe(onNext: { _ in
                coordinator.pop()
            })
            .disposed(by: disposeBag)
        
        
        onCancel.executionObservables
            .take(1)
            .subscribe(onNext: { _ in
                coordinator.pop()
            })
            .disposed(by: disposeBag)
    }
    
    /** The UpdateAction called when the save button is pressed. Triggers update in the task service. */
    lazy var onUpdate: Action<(String?, String?, String?, String?, Int), RealmTask> = { this in
        return Action { (name, description, dueDate, activity, progress) in
            var due = this.task.Due
            if let dateVal = dueDate {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yy"
                if let date = dateFormatter.date(from: dateVal) {
                    due = date
                }
            }
            
            if this.isNew {
                return this.taskService.createTask(title: name ?? "", description: description ?? "", due: due, activity: activity ?? "", officers: "", proofs: [String]())
            }
            
            this.task.Title = name ?? ""
            this.task.Description = description ?? ""
            this.task.Due = due
            this.task.Activity = activity ?? ""
            this.task.Progress = progress
            return this.taskService.update(task: this.task)
        }
    }(self)
    
    /** The CancelAction called when the cancel button is pressed. Deletes the task if it is empty and cancels. */
    lazy var onCancel: Action<(String?, String?, String?, String?, Int), Void> = { this in
        return Action { (name, description, dueDate, activity, progress) in
            return Observable.empty()
        }
    }(self)
}
