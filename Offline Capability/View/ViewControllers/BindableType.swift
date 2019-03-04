import UIKit
import RxSwift

/**
 * Protocol which every ViewController needs to implement in order to provide binding to the view model
 */
protocol BindableType {
    /** The type of the viewmodel which is bound to the according view controller */
    associatedtype ViewModelType
    
    /** The view model instance which is bound to the view controller */
    var viewModel: ViewModelType! { get set }
    
    /** Binds the Properties of the viewmodel to the ui controls and connects eventual actions */
    func bindViewModel()
}

/** Extension of BindableType which sets the viewModel and then binds the viewmodel to the view controller */
extension BindableType where Self: UIViewController {
    mutating func bindViewModel(to model: Self.ViewModelType){
        viewModel = model
        loadViewIfNeeded()
        bindViewModel()
    }
}
