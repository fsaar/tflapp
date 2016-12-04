import UIKit
import MapKit

class TFLMapViewAnnotation: NSObject,MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    let identifier : String
    override public var debugDescription: String {
        return "\(title) - \(subtitle) [\(identifier)]"
    }
    
    init(with title : String ,and subTitle: String, for coordinate: CLLocationCoordinate2D, with identifier : String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subTitle
        self.identifier = identifier
        super.init()
    }
}

extension TFLMapViewAnnotation {
    public static func ==(lhs: TFLMapViewAnnotation,rhs :TFLMapViewAnnotation) -> (Bool) {
        return lhs.identifier == rhs.identifier
    }
    override public var hashValue: Int {
        return self.identifier.hashValue
    }

}
