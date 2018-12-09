import UIKit

extension UIFont {
    class func tflBoldFont(size : CGFloat) -> UIFont {
        let descriptor = UIFontDescriptor(name: "GillSans-Bold", size: size)
        let font = UIFont(descriptor: descriptor, size: size)
        return font
    }

    class func tflFont(size : CGFloat) -> UIFont {
        let descriptor = UIFontDescriptor(name: "GillSans", size: size)
        let font = UIFont(descriptor: descriptor, size: size)
        return font
    }
    
    class func tflStationDetailErrorTitle() -> UIFont {
        let descriptor = UIFontDescriptor(name: "GillSans-Light", size: 20)
        let font = UIFont(descriptor: descriptor, size: 20)
        return font
    }
    
    class func tflUpdateStatusPendingTitle() -> UIFont {
        let descriptor = UIFontDescriptor(name: "GillSans", size: 14)
        let font = UIFont(descriptor: descriptor, size: 14)
        return font
    }
    
    class func tflHUDTitle() -> UIFont {
        let descriptor = UIFontDescriptor(name: "GillSans-Light", size: 24)
        let font = UIFont(descriptor: descriptor, size: 24)
        return font
    }
    
    class func tflRefreshTitle() -> UIFont {
        let descriptor = UIFontDescriptor(name: "GillSans-Light", size: 12)
        let font = UIFont(descriptor: descriptor, size: 12)
        return font
    }

    class func tflStationDetailHeader() -> UIFont {
        let descriptor = UIFontDescriptor(name: "GillSans", size: 20)
        let font = UIFont(descriptor: descriptor, size: 20)
        return font
    }

    class func tflStationDetailNearbyTitle() -> UIFont {
        let descriptor = UIFontDescriptor(name: "GillSans-Light", size: 12)
        let font = UIFont(descriptor: descriptor, size: 12)
        return font
    }
    
    class func tflStationDetailTitle() -> UIFont {
        let descriptor = UIFontDescriptor(name: "GillSans-Light", size: 17)
        let font = UIFont(descriptor: descriptor, size: 17)
        return font
    }

    class func tflStationDetailSectionHeaderTitle() -> UIFont {
        let descriptor = UIFontDescriptor(name: "GillSans", size: 17)
        let font = UIFont(descriptor: descriptor, size: 17)
        return font
    }
    class func tflStationDetailStopCode() -> UIFont {
        let descriptor = UIFontDescriptor(name: "GillSans", size: 14)
        let font = UIFont(descriptor: descriptor, size: 14)
        return font
    }

    class func tflFontStationHeader() -> UIFont {
        let descriptor = UIFontDescriptor(name: "GillSans-Light", size: 17)
        let font = UIFont(descriptor: descriptor, size: 17)
        return font
    }

    class func tflFontStationDetails() -> UIFont {
        let descriptor = UIFontDescriptor(name: "GillSans-Light", size: 15)
        let font = UIFont(descriptor: descriptor, size: 15)
        return font
    }

    class func tflFontStationDistance() -> UIFont {
        let descriptor = UIFontDescriptor(name: "GillSans-Light", size: 14)
        let font = UIFont(descriptor: descriptor, size: 14)
        return font
    }

    class func tflFontStationIdentifier() -> UIFont {
        let descriptor = UIFontDescriptor(name: "GillSans", size: 14)
        let font = UIFont(descriptor: descriptor, size: 14)
        return font
    }

    class func tflFontBusLineIdentifier() -> UIFont {
        let descriptor = UIFontDescriptor(name: "GillSans", size: 14)
        let font = UIFont(descriptor: descriptor, size: 14)
        return font
    }

    class func tflFontBusArrivalTime() -> UIFont {
        let descriptor = UIFontDescriptor(name: "GillSans-Light", size: 15)
        let font = UIFont(descriptor: descriptor, size: 15)
        return font
    }

    class func tflFontMapBusStationIdentifier() -> UIFont {
        let descriptor = UIFontDescriptor(name: "GillSans", size: 14)
        let font = UIFont(descriptor: descriptor, size: 14)
        return font
    }

    class func tflFontPoweredBy() -> UIFont {
        let descriptor = UIFontDescriptor(name: "GillSans-Light", size: 17)
        let font = UIFont(descriptor: descriptor, size: 17)
        return font
    }
}
