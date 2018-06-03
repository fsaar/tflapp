import UIKit
import CoreData

struct TFLStationDetailMapViewModel {
    
    let stations : [(stopCode: String,name : String)]
        
    
    init?(with route: TFLCDLineRoute) {
        guard let managedObjectContext = route.managedObjectContext else {
            return nil
        }
        let routeStations = route.stations ?? []
        let busStops = TFLCDBusStop.busStops(with: routeStations, and: managedObjectContext)
        let tuples = busStops.map { ($0.stopLetter ?? "",$0.name) }
        stations = tuples
    }
}
