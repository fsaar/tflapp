import UIKit
import CoreData

struct TFLStationDetailTableViewModel {
    
    let routeName : String
    let stations : [(stopCode: String,name : String)]
        
    
    init?(with route: TFLCDLineRoute) {
        enum HtmlEncodings : String {
            case towards = "&harr;"
        }
        guard let managedObjectContext = route.managedObjectContext else {
            return nil
        }
        let routeStations = route.stations ?? []
        let busStops = TFLCDBusStop.busStops(with: routeStations, and: managedObjectContext)
        let tuples = busStops.map { ($0.stopLetter ?? "",$0.name) }
        let towards = NSLocalizedString("TFLStationDetailTableViewModel.towards", comment: "")
        let tempName = route.name.replacingOccurrences(of: HtmlEncodings.towards.rawValue, with: towards)
        let tempNameComponents = tempName.split(separator: " ").map { $0.trimmingCharacters(in: .whitespaces ) }.filter { !$0.isEmpty }
        routeName = tempNameComponents.joined(separator: " ")
        stations = tuples
    }
}
