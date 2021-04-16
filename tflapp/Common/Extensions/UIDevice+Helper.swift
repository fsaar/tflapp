

import Foundation
import UIKit

extension UIDevice {
    
    static var isIPad : Bool {
        let window = UIApplication.shared.windows.first
        let isIPad1 =  window?.traitCollection.userInterfaceIdiom == UIUserInterfaceIdiom.pad
        let isIPad2 = self.current.model.hasPrefix("iPad")
        return isIPad1 || isIPad2
    }
}
