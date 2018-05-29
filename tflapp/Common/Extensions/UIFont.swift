import UIKit

extension UIFont {
    class func tflBoldFont(size : CGFloat) -> UIFont {
        let font = UIFont(name: "GillSans-Bold", size: size)
        return font!
    }
    
    class func tflFont(size : CGFloat) -> UIFont {
        let font = UIFont(name: "GillSans", size: size)
        return font!
    }
    
    class func tflStationDetailHeader() -> UIFont {
        let font = UIFont(name: "GillSans", size: 20)
        return font!
    }
    
    class func tflFontStationHeader() -> UIFont {
        let font = UIFont(name: "GillSans-Light", size: 17)
        return font!
    }
    
    class func tflFontStationDetails() -> UIFont {
        let font = UIFont(name: "GillSans-Light", size: 15)
        return font!
    }
    
    class func tflFontStationDistance() -> UIFont {
        let font = UIFont(name: "GillSans-Light", size: 14)
        return font!
    }
    
    class func tflFontStationIdentifier() -> UIFont {
        let font = UIFont(name: "GillSans", size: 14)
        return font!
    }
    
    class func tflFontBusLineIdentifier() -> UIFont {
        let font = UIFont(name: "GillSans", size: 14)
        return font!
    }
    
    class func tflFontBusArrivalTime() -> UIFont {
        let font = UIFont(name: "GillSans-Light", size: 15)
        return font!
    }
    
    class func tflFontMapBusStationIdentifier() -> UIFont {
        let font = UIFont(name: "GillSans", size: 14)
        return font!
    }
    
    class func tflFontPoweredBy() -> UIFont {
        let font = UIFont(name: "GillSans-Light", size: 17)
        return font!
    }
}
