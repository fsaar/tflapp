import UIKit
import CoreData
import MapKit


extension Array where Element == TFLStationDetailTableViewModel {
    func indexPaths(for models : [TFLVehicleArrivalInfo]) -> [IndexPath] {
        let naptanIdentifiers = models.map{ $0.busStopIdentifier }
        let paths = indexPaths(for: naptanIdentifiers)
        return paths
    }
    
    
    func indexPath(for station : String) -> IndexPath? {
        let paths = indexPaths(for: [station])
        return paths.first
    }
    
    func indexPaths(for naptanIdentifiers : [String]) -> [IndexPath] {
        let indexPaths : [IndexPath] = self.naptanIDLists.enumerated().reduce([]) { sum,tuple in
            let (section,naptanIDList) = tuple
            let sectionIndexPaths = naptanIdentifiers.compactMap{ naptanIDList.firstIndex(of:$0) }
                                                        .map{ IndexPath(row:$0,section:section) }
            return sum + sectionIndexPaths
        }
        return indexPaths
    }
    
    // viewModels[section] -> stations[indexPath.row]
    //                              |- naptandId == arrivalInfo.busStopIdentifer
    var naptanIDLists : [[String]] {
        let lists : [[String]] = self.reduce([]) { sum,model in
            let modelNaptanIds = model.stations.map{ $0.naptanId }
            return sum + [modelNaptanIds]
        }
        return lists
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
        let stationDistanceTuple = busStops.map{ ($0,$0.distance(to:location)) }.min  { $0.1 < $1.1 }
        if let stationDistanceTuple = stationDistanceTuple, stationDistanceTuple.1 < minClostedStationDistance {
            closestStationIdentifer = stationDistanceTuple.0.stationIdentifier
        }
        else {
            closestStationIdentifer = nil
        }
        let tuples = busStops.map{ ($0.stopLetter ?? "",$0.name,$0.stationIdentifier,$0.identifier) }
        
        let towards = NSLocalizedString("Common.towards", comment: "")
        let tempName = route.name.replacingOccurrences(of: HtmlEncodings.towards.rawValue, with: towards)
        let tempNameComponents = tempName.split(separator: " ").map{ $0.trimmingCharacters(in: .whitespaces ) }.filter{ !$0.isEmpty }
        routeName = tempNameComponents.joined(separator: " ")
        stations = tuples
    }

    func showAnimation(for index : Int) -> Bool {
        return stations[index].identifer == closestStationIdentifer
    }
}
