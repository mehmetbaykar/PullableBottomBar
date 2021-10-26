import UIKit

extension UIViewController {
    func addContainerView(_ viewController: UIViewController, view: UIView? = nil) {
        guard let targetView = view ?? viewController.view else { return }
        addChild(viewController)
        self.view.addSubview(targetView)
        self.view.bringSubviewToFront(targetView)
        viewController.didMove(toParent: self)
    }
}
