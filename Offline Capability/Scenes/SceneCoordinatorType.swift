import UIKit
import RxSwift

/** Protocol describing the exposed functions of the Coordinator providing the needed functionality. */
protocol SceneCoordinatorType {
    /** Transitions to a new scene with the given transition type
 - Parameter scene: Scene to transition to
 - Parameter type: type of transition
 */
    @discardableResult
    func transition(to scene: Scene, type: SceneTransitionType) -> Completable
    
    /** Pops the current scene and navigates back to the last one
 - Parameter animated: if the navigation should be animated
     */
    @discardableResult
    func pop(animated: Bool) -> Completable
}

/** Extension to provide an animated behaviour as default for the pop function */
extension SceneCoordinatorType {
    @discardableResult
    func pop() -> Completable {
        return pop(animated: true)
    }
}
