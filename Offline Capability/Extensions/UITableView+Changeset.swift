
import UIKit

/** Extension to add Changeset functionality to table views */
extension UITableView {
    /** Applies the changeset to the table view by deleting, inserting or reloading rows of the table view */
    func applyChangeSet(deleted: [Int], inserted: [Int], updated: [Int]) {
        beginUpdates()
        deleteRows(at: deleted.map { IndexPath(row: $0, section: 0)}, with: .automatic)
        insertRows(at: inserted.map { IndexPath(row: $0, section: 0)}, with: .automatic)
        reloadRows(at: updated.map { IndexPath(row: $0, section: 0)}, with: .automatic)
        endUpdates()
    }
}
