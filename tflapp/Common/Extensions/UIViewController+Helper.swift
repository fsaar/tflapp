//
//  UIViewController+Helper.swift
//  tflapp
//
//  Created by Frank Saar on 13/02/2019.
//  Copyright © 2019 SAMedialabs. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func removeController(_ controller : UIViewController?) {
        controller?.willMove(toParent: nil)
        controller?.view.removeFromSuperview()
        controller?.removeFromParent()
    }
}

extension UIViewController : UIGestureRecognizerDelegate {
}

extension UIViewController : UINavigationControllerDelegate {
    public func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        if let navController = self.navigationController,  let rootViewController = navController.viewControllers.first,let popGestureRecognizer = navController.interactivePopGestureRecognizer {
            guard rootViewController === popGestureRecognizer.delegate else  {
                return
            }
            popGestureRecognizer.isEnabled = navController.viewControllers.count <= 1  ? false : true

        }
    }
   
}
