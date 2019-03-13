import UIKit
import Action
import RxSwift

/** Cell to hold Tasks */
class TaskTableViewCell: UITableViewCell {
    
    /** indicator displayed left of the cell */
    @IBOutlet weak var indicator: UIView!
    /** label for the name of the task */
    @IBOutlet weak var name: UILabel!
    /** label for the date of the task */
    @IBOutlet weak var due: UILabel!
    /** lable for the description of the task */
    @IBOutlet weak var taskDescription: UILabel!
    
    /** DispoaseBag handling automatic disposal of observables */
    var disposeBag = DisposeBag()
    
    /** Configures the cell for the item by binding the fields to the item values
     - Parameter item: the item to configure the cell for
     */
    func configure(with item: RealmTask) {
        indicator.layer.cornerRadius = indicator.frame.size.width/2
        indicator.clipsToBounds = true
        
        item.rx.observe(String.self, "Title")
            .subscribe(onNext: { [weak self] title in
                self?.name.text = title
            })
            .disposed(by: disposeBag)
        
        item.rx.observe(Date.self, "Due")
            .subscribe(onNext: { [weak self] date in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.yy"
                if let date = date {
                    self?.due.text = "bis \(dateFormatter.string(from: date))"
                }
            })
            .disposed(by: disposeBag)
        
        item.rx.observe(String.self, "Description")
            .subscribe(onNext: { [weak self] description in
                self?.taskDescription.text = description
            })
            .disposed(by: disposeBag)
        
        self.taskDescription.numberOfLines = 3
        self.taskDescription.lineBreakMode = .byWordWrapping
    }
    
    /** Creates a new disposeBag for reused cells */
    override func prepareForReuse() {
        disposeBag = DisposeBag()
        super.prepareForReuse()
    }
}
