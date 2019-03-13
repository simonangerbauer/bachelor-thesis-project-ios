import UIKit
import RxSwift
import RxDataSources
import Action
import NSObject_Rx

/**
 TasksViewController connects the viewModel to the Tasks View
 */
class TasksViewController: UIViewController, BindableType {
    /** TableView to display tasks in */
    @IBOutlet var tableView: UITableView!
    /** Add Button to add new task */
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    /** The bound view model */
    var viewModel: TasksViewModel!
    
    /** Called when the view did load. Sets the tableView delegate and datasource */
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self;
        tableView.delegate = self;
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 105
        
        setEditing(true, animated: true)
    }
    
    /** Binds the Properties of the viewmodel to the ui controls and connects eventual actions */
    func bindViewModel() {
        
        viewModel.changesets
            .subscribe(onNext: { [weak self] changeset in
                if changeset.deleted.count == 0 && changeset.inserted.count == 0 && changeset.updated.count == 0 {
                    DispatchQueue.main.async {
                        self?.tableView?.reloadData()
                    }
                } else {
                    self?.tableView?.applyChangeSet(deleted: changeset.deleted, inserted: changeset.inserted, updated: changeset.updated)
                }
            })
            .disposed(by: self.rx.disposeBag)
        
        addButton.rx.action = viewModel.onCreateTask()
        
    }
}

/** Extension for implementing the UITableViewDataSource methods */
extension TasksViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let task = viewModel.tasks[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "TaskCell") as! TaskTableViewCell
        cell.configure(with: task)
        return cell
    }
}

/** Extension for implementing the UITableViewDelegate methods */
extension TasksViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        //viewModel.editAction.execute(viewModel.tasks[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == .delete) {
            let task = viewModel.tasks[indexPath.row]
            //viewModel.delete(task: task)
        }
    }
}


