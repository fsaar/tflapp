import UIKit
import MapKit

class TFLStationDetailMapViewAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let priority : MKFeatureDisplayPriority
    var title: String? {
        return stopCode
    }
    private let stopCode: String
    var identifier : String {
        return stopCode
    }
    override public var debugDescription: String {
        return "\(String(describing: title)) [\(identifier)]"
    }
    
    init(with stopCode : String,coordinate: CLLocationCoordinate2D,and index : Int) {
        self.stopCode = stopCode
        self.coordinate = coordinate
        self.priority = MKFeatureDisplayPriority(rawValue: min(Float(index),1000))
        super.init()
    }
}

extension TFLStationDetailMapViewAnnotation {
    public static func ==(lhs: TFLStationDetailMapViewAnnotation,rhs :TFLStationDetailMapViewAnnotation) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    override public var hashValue: Int {
        return self.identifier.hashValue
    }

}
