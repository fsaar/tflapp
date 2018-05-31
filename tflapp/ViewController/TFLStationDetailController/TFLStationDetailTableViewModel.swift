import UIKit


struct TFLStationDetailTableViewModel {
 
    let routeName : NSAttributedString
    let stations : [(stopCode: String,name : String)]
    
    //CFURLCreateStringByReplacingPercentEscapes
    
    init?(with route: TFLCDLineRoute) {
        guard let managedObjectContext = route.managedObjectContext else {
            return nil
        }
        let busStops = TFLCDBusStop.busStops(with: route.stations ?? [], and: managedObjectContext)
        let tuples = busStops.map { ($0.stopLetter ?? "",$0.name) }
        let attributedString = (try? NSAttributedString(data:  route.name.data(using: .utf8)!, options:[.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)) ?? NSAttributedString(string: "")
        routeName = attributedString
        stations = tuples
    }
}
