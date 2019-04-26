import UIKit
import MapKit

class TFLStationDetailMapViewAnnotation: NSObject, MKAnnotation {
    let coordinate: CLLocationCoordinate2D
    let priority : MKFeatureDisplayPriority
    let identifier : String
    var title: String? {
        return stopCode
    }
    private let stopCode: String
    override public var debugDescription: String {
        return "\(String(describing: title)) [\(identifier) - \(stopCode)]"
    }

    init(with identifier : String,stopCode : String,coordinate: CLLocationCoordinate2D,and index : Int) {
        self.stopCode = stopCode
        self.coordinate = coordinate
        self.priority = MKFeatureDisplayPriority(rawValue: min(Float(index),1000))
        self.identifier = identifier
        super.init()
    }
}
