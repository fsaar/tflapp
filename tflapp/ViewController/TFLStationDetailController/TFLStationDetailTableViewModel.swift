import UIKit
import CoreData
import MapKit

extension Array where Element == TFLStationDetailTableViewModel {
    // viewModels[section] -> stations[indexPath.row]
    //                              |- naptandId == arrivalInfo.busStopIdentifer
    func indexPaths(for models : [TFLVehicleArrivalInfo]) -> [IndexPath] {
        let indexPaths : [IndexPath] = self.enumerated().reduce([]) { sum,tuple in
            let (section,model) = tuple
            let sectionIndexPaths : [IndexPath] = model.stations.enumerated().compactMap { tuple in
                let (row,stationTuple) = tuple
                guard let _ = models.info(with: stationTuple.naptanId) else {
                    return nil
                }
                return IndexPath(row: row, section: section)
            }
            return sum + sectionIndexPaths
        }
        return indexPaths
    }
    
    func indexPath(for station : String) -> IndexPath? {
        let indexPaths : [IndexPath] = self.enumerated().reduce([]) { sum,tuple in
            let (section,model) = tuple
            let sectionIndexPaths : [IndexPath] = model.stations.enumerated().compactMap { tuple in
                let (row,stationTuple) = tuple
                guard station == stationTuple.naptanId else {
                    return nil
                }
                return IndexPath(row: row, section: section)
            }
            guard let indexPath = sectionIndexPaths.first else {
                return sum
            }
            return sum + [indexPath]
        }
        return indexPaths.first
    }
}

struct TFLStationDetailTableViewModel {
    let minClostedStationDistance : Double = 50
    let routeName : String
    let stations : [(stopCode: String,name : String,identifer: String,naptanId:String)]
    fileprivate let closestStationIdentifer : String?

    init?(with route: TFLCDLineRoute,location : CLLocation) {
        enum HtmlEncodings : String {
            case towards = "&harr;"
        }
        guard let managedObjectContext = route.managedObjectContext else {
            return nil
        }
        let routeStations = route.stations ?? []
        let busStops = TFLCDBusStop.busStops(with: routeStations, and: managedObjectContext)
        let stationDistanceTuple = busStops.map { ($0,$0.distance(to:location) )}.min  { $0.1 < $1.1}
        if let stationDistanceTuple = stationDistanceTuple, stationDistanceTuple.1 < minClostedStationDistance {
            closestStationIdentifer = stationDistanceTuple.0.stationIdentifier
        }
        else {
            closestStationIdentifer = nil
        }
        let tuples = busStops.map { ($0.stopLetter ?? "",$0.name,$0.stationIdentifier,$0.identifier) }
        
        let towards = NSLocalizedString("TFLStationDetailTableViewModel.towards", comment: "")
        let tempName = route.name.replacingOccurrences(of: HtmlEncodings.towards.rawValue, with: towards)
        let tempNameComponents = tempName.split(separator: " ").map { $0.trimmingCharacters(in: .whitespaces ) }.filter { !$0.isEmpty }
        routeName = tempNameComponents.joined(separator: " ")
        stations = tuples
    }

    func showAnimation(for index : Int) -> Bool {
        return stations[index].identifer == closestStationIdentifer
    }
}
