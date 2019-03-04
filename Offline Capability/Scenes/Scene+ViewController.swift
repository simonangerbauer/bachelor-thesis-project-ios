import UIKit

extension Scene {
    /** instantiates the viewController on the storyboard and binds it to the viewModel
     - Returns: the instantiated UIViewController
     */
    func viewController() -> UIViewController {
        
        switch self {
            
        case .tasks (let viewModel):
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let navigationController = storyboard.instantiateViewController(withIdentifier: "Tasks") as! UINavigationController
            var viewController = navigationController.viewControllers.first as! TasksViewController
            viewController.bindViewModel(to: viewModel)
            return navigationController
        
        /*case .editTask (let viewModel):
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let navigationController = storyboard.instantiateViewController(withIdentifier: "EditTask") as! UINavigationController
            var viewController = navigationController.viewControllers.first as! EditTaskViewController
            viewController.bindViewModel(to: viewModel)
            return navigationController*/
        }
    }
}
