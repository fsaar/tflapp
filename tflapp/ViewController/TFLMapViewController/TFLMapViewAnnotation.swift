import UIKit
import MapKit

class TFLMapViewAnnotation: NSObject,MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let title: String?
    let subtitle: String?
    let identifier : String
    override public var debugDescription: String {
        return "\(String(describing: title)) - \(String(describing: subtitle)) [\(identifier)]"
    }
    
    init(for coordinate: CLLocationCoordinate2D, with identifier : String,with title : String? = nil ,and subTitle: String? = nil) {
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
