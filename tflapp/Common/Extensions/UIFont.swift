import UIKit

extension UIFont {
    class func tflBoldFont(size : CGFloat) -> UIFont {
        let font = UIFont(name: "Verdana-Bold", size: size)
        return font!
    }
    
    class func tflFont(size : CGFloat) -> UIFont {
        let font = UIFont(name: "Verdana", size: size)
        return font!
    }
}
