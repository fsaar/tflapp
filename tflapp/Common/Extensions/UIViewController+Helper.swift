
import Foundation
import UIKit


extension UIViewController : UIGestureRecognizerDelegate {
}

extension UIViewController : UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if let navController = self.navigationController,  let rootViewController = navController.viewControllers.first,let popGestureRecognizer = navController.interactivePopGestureRecognizer {
            guard rootViewController === popGestureRecognizer.delegate else  {
                return
            }
            popGestureRecognizer.isEnabled = navController.viewControllers.count == 1  ? false : true

        }
    }
   
}
extension UIViewController {
    func removeController(_ controller : UIViewController?) {
        controller?.willMove(toParent: nil)
        controller?.view.removeFromSuperview()
        controller?.removeFromParent()
    }
    
    func addController(_ controller : UIViewController) {
        self.addChild(controller)
        controller.view.frame = self.view.frame
        self.view.addSubview(controller.view)
        controller.didMove(toParent: self)
        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: self.view.topAnchor),
            controller.view.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            controller.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])
    }
    
    func setupBackSwipe() {
        guard !UIDevice.isIPad,
              let navController = self.navigationController,navController.viewControllers.first === self else {
            return
        }
        navController.interactivePopGestureRecognizer?.delegate = self
        navController.delegate = self
    }
}
