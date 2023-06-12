

import Foundation
import UIKit

extension UIDevice {
    
    static var isIPad : Bool {
        let isIpad = UIDevice.current.userInterfaceIdiom == .phone
        return isIpad
    }
}
