import UIKit
import RxSwift
import RxCocoa

/** Handles Navigation between scenes */
class SceneCoordinator: SceneCoordinatorType {
    /** The window to set the view on */
    private var window: UIWindow
    /** The current view controller displayed in the window */
    private var currentViewController: UIViewController
    
    required init(window: UIWindow) {
        self.window = window
        currentViewController = window.rootViewController!
    }
    
    /** returns the child of the navigationController instead of the navigationController which doesn't hold the actual state
 - Parameter viewController: the ViewController to get the child of
     - Returns: The Child view controller if available
     */
    static func actualViewController(for viewController: UIViewController) -> UIViewController {
        if let navigationController = viewController as? UINavigationController {
            return navigationController.viewControllers.first!
        } else {
            return viewController
        }
    }
    
    /** Transitions to a new scene with the given transition type
 - Parameter scene: Scene to transition to
 - Parameter type: type of transition
     */
    @discardableResult
    func transition(to scene: Scene, type: SceneTransitionType) -> Completable {
        let subject = PublishSubject<Void>()
        let viewController = scene.viewController()
        switch type {
            case .root:
                currentViewController = SceneCoordinator.actualViewController(for: viewController)
                window.rootViewController = viewController
                subject.onCompleted()
            
            case .push:
                guard let navigationController = currentViewController.navigationController else {
                    fatalError("Can't push a view controller without a current navigation controller")
                }
                
                _ = navigationController.rx.delegate
                    .sentMessage(#selector(UINavigationControllerDelegate.navigationController(_:didShow:animated:)))
                    .map { _ in}
                    .bind(to: subject)
                
                navigationController.pushViewController(viewController, animated: true)
                currentViewController = SceneCoordinator.actualViewController(for: viewController)
            
            case .modal:
                currentViewController.present(viewController, animated: true) {
                    subject.onCompleted()
                }
            
                currentViewController = SceneCoordinator.actualViewController(for: viewController)
        }
        
        return subject.asObservable()
            .take(1)
            .ignoreElements()
    }
    
    /** Pops the current scene and navigates back to the last one
 - Parameter animated: if the navigation should be animated
     */
    func pop(animated: Bool) -> Completable {
        let subject = PublishSubject<Void>()
        if let presenter = currentViewController.presentingViewController {
            currentViewController.dismiss(animated: animated) {
                self.currentViewController = SceneCoordinator.actualViewController(for: presenter)
                subject.onCompleted()
            }
        } else if let navigationController = currentViewController.navigationController {
            _ = navigationController.rx.delegate
                .sentMessage(#selector(UINavigationControllerDelegate.navigationController(_:didShow:animated:)))
                .map { _ in }
                .bind(to: subject)
            
            guard navigationController.popViewController(animated: animated) != nil else {
                fatalError("can't navigate back from \(currentViewController)")
            }
            
            currentViewController = SceneCoordinator.actualViewController(for: navigationController.viewControllers.last!)
        } else {
            fatalError("Not a modal, no navigation controller - can't navigate back from \(currentViewController)")
        }
        
        return subject.asObservable()
            .take(1)
            .ignoreElements()
    }
}
