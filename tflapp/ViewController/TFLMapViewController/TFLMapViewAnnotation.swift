import UIKit
import MapKit

class TFLMapViewAnnotation: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D {
        return arrivalsInfo.busStop.coord
    }
    var title: String? {
        return arrivalsInfo.busStop.stopLetter
    }
    let arrivalsInfo: TFLBusStopArrivalsInfo
    var identifier : String {
        return arrivalsInfo.identifier
    }
    override public var debugDescription: String {
        return "\(String(describing: title)) [\(identifier)]"
    }

    init(with arrivalsInfo: TFLBusStopArrivalsInfo) {
        self.arrivalsInfo = arrivalsInfo
        super.init()
    }
}
