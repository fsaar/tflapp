import UIKit
import CoreData
import MapKit

struct TFLStationDetailMapViewModel {
    let stations : [(identifier:String, stopCode: String,coords : CLLocationCoordinate2D,stopDescription:String?)]
    let coords : [CLLocationCoordinate2D]
    init?(with route: TFLCDLineRoute) {
        func stopDescription(with busStop : TFLCDBusStop) -> String? {
            let towards = busStop.towards != nil ? "towards \(busStop.towards ?? "")" : ""
            guard let stopLetter = busStop.stopLetter else {
                return "\(busStop.name) \(busStop.name) \(towards)"
            }
            return "\(stopLetter) - \(busStop.name) \(towards)"
        }

        guard let managedObjectContext = route.managedObjectContext else {
            return nil
        }
        let routeStations = route.stations ?? []
        let busStops = TFLCDBusStop.busStops(with: routeStations, and: managedObjectContext)
  
        let tuples = busStops.map { ($0.identifier,$0.stopLetter ?? "",CLLocationCoordinate2DMake($0.lat, $0.long),stopDescription(with: $0)) }.filter { $0.2.isValid }
        stations = tuples
        let polyline = PolyLine(precision: 5)
        let polylineString = route.polyline ?? ""
        let decodedCoords =  polyline.decode(polyLine: polylineString)
        coords = decodedCoords.isEmpty ? stations.map { $0.coords } : decodedCoords
    }
}
