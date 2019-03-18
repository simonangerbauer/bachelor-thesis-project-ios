import UIKit
import Foundation
import RxSwift
import RxCocoa
import Action
import NSObject_Rx

/** EditTaskViewController connects the viewModel to the EditTask Layout */
class EditTaskViewController: UIViewController, BindableType {
    /** task name text field */
    @IBOutlet weak var name: UITextField!
    /** progress value slider */
    @IBOutlet weak var progress: UISlider!
    /** task description text view */
    @IBOutlet weak var taskDescription: UITextView!
    /** the button used to cancel edit */
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    /** the button used to save the edit */
    @IBOutlet weak var saveButton: UIBarButtonItem!
    /** due date text field */
    @IBOutlet weak var dueDate: UITextField!
    /** activity text view */
    @IBOutlet weak var activity: UITextView!
    
    /** the bound view model */
    var viewModel: EditTaskViewModel!
    
    /** Binds the properties of the task to the input fields and binds the save and cancel actions */
    func bindViewModel() {
        name.text = viewModel.task.Title
        taskDescription.text = viewModel.task.Description
        progress.value = Float(viewModel.task.Progress)/100
        activity.text = viewModel.task.Activity
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        dueDate.text = dateFormatter.string(from: viewModel.task.Due)
        
        let nameText = name.rx.text.asObservable()
        let descriptionText = taskDescription.rx.text.asObservable()
        let dueDateText = self.dueDate.rx.text.asObservable()
        let activityText = activity.rx.text.asObservable()
        let progressVal = progress.rx.value.asObservable().map { value in
            return Int(value*100)
        }
        
        let combinedObservables = Observable.combineLatest(nameText, descriptionText, dueDateText, activityText, progressVal)
        
        saveButton.rx.tap
            .withLatestFrom(combinedObservables)
            .subscribe(viewModel.onUpdate.inputs)
            .disposed(by: self.rx.disposeBag)
        
        cancelButton.rx.tap
            .withLatestFrom(combinedObservables)
            .subscribe(viewModel.onCancel.inputs)
            .disposed(by: self.rx.disposeBag)
    }
}
