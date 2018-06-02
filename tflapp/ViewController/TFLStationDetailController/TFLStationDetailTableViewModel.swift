import UIKit
import CoreData

struct TFLStationDetailTableViewModel {
 
    let routeName : String
    let stations : [(stopCode: String,name : String)]
        
    
    init?(with route: TFLCDLineRoute) {
        guard let managedObjectContext = route.managedObjectContext else {
            return nil
        }
        let routeStations = route.stations ?? []
        let busStops = TFLCDBusStop.busStops(with: routeStations, and: managedObjectContext)
        let busStopsDict = Dictionary(grouping: busStops) { $0.identifier }
        let sortedBusStops = routeStations.compactMap { busStopsDict[$0]?.first }
        let tuples = sortedBusStops.map { ($0.stopLetter ?? "",$0.name) }
        routeName = route.name
        stations = tuples
    }
}
