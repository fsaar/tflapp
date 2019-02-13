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
