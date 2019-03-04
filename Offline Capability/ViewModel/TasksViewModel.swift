import Foundation
import RxSwift
import RxDataSources
import Action

/** Provides business logic for the TasksViewController */
class TasksViewModel {
    /** The Coordinator used to navigation to and from this scene */
    let sceneCoordinator: SceneCoordinatorType
    /** the service to provide task data */
    let taskService: TaskServiceType
    /** Used for automatic disposal of added observables */
    let disposeBag = DisposeBag()
    /** Array of tasks to be displayed */
    var tasks: [RealmTask]
    /** Observable of Changesets containing the changes to the objects */
    var changesets: Observable<Changeset<RealmTask>>
    
    /** injects dependencies and gets initial items
     - parameter taskService: Service to be injected
     - parameter coordinator: Coordinator for navigation
     */
    init(taskService: TaskServiceType, coordinator: SceneCoordinatorType) {
        self.taskService = taskService
        self.sceneCoordinator = coordinator
        self.tasks = [RealmTask]()
        
        self.changesets = self.taskService.tasks()
        
        self.changesets.subscribe(onNext: { [weak self] (changeset) in
            if let `self` = self {
                self.tasks = changeset.results
            }
        })
            .disposed(by: disposeBag)
    }
    
    /** CreateAction called when a new task needs to be created
     - Returns: CocoaAction used for binding to Button
     */
    func onCreateTask() -> CocoaAction {
        return CocoaAction { _ in
            return self.taskService
                .createTask(title: "", description: "", due: Date(), activity: "", officers: "", proofs: [String]())
                .flatMap { task -> Observable<Void> in
                    return Observable.empty()
                /*
                    let editTaskViewModel = EditTaskViewModel(coordinator: self.sceneCoordinator, taskService: self.taskService, task: task)
                    
                    return self.sceneCoordinator
                        .transition(to: Scene.editTask(editTaskViewModel), type: .modal)
                        .asObservable().map { _ in }
            }*/
        }
    }
    
    /** Deletes the task
     - Parameter task: the task to be deleted
     - Returns: Observable without value to observe for completion
     */
    @discardableResult
    func delete(task: RealmTask) -> Observable<Void> {
        return taskService.delete(task: task)
    }
    
    /** EditAction is called when a Task needs to be edited. Navigates to the EditTask Scene. */
    /*lazy var editAction: Action<Task, Swift.Never> = { this in
        return Action { task in
            let editTaskViewModel = EditTaskViewModel(coordinator: this.sceneCoordinator, taskService: this.taskService, task: task)
            
            return this.sceneCoordinator
                .transition(to: Scene.editTask(editTaskViewModel), type: .modal)
                .asObservable()
        }
    }(self)*/
    }
}
