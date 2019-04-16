import UIKit
import CoreData
import MapKit

struct TFLStationDetailMapViewModel {
    let stations : [(stopCode: String,coords : CLLocationCoordinate2D)]
    let coords : [CLLocationCoordinate2D]
    init?(with route: TFLCDLineRoute) {
        guard let managedObjectContext = route.managedObjectContext else {
            return nil
        }
        let routeStations = route.stations ?? []
        let busStops = TFLCDBusStop.busStops(with: routeStations, and: managedObjectContext)
  
        let tuples = busStops.map { ($0.stopLetter ?? "",CLLocationCoordinate2DMake($0.lat, $0.long)) }.filter { $0.1.isValid }
        stations = tuples
        let polyline = PolyLine(precision: 5)
        let polylineString = route.polyline ?? ""
        let decodedCoords =  polyline.decode(polyLine: polylineString)
        coords = decodedCoords.isEmpty ? stations.map { $0.coords } : decodedCoords
    }
}
