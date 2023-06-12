import Foundation
import CoreData
import CoreLocation
import os.signpost

/*
 [{
    "$type": "Tfl.Api.Presentation.Entities.Prediction, Tfl.Api.Presentation.Entities",
    "id": "-447807801",
    "operationType": 1,
    "vehicleId": "YY66OYB",
    "naptanId": "490015185H",
    "stationName": "Trocadero / Haymarket",
    "lineId": "14",
    "lineName": "14",
    "platformName": "H",
    "direction": "outbound",
    "bearing": "21",
    "destinationNaptanId": "",
    "destinationName": "Warren Street",
    "timestamp": "2017-06-17T13:44:20.1741351Z",
    "timeToStation": 848,
    "currentLocation": "",
    "towards": "Holborn or Warren Street Station",
    "expectedArrival": "2017-06-17T13:58:28Z",
    "timeToLive": "2017-06-17T13:58:58Z",
    "modeName": "bus",
    "timing": {
        "$type": "Tfl.Api.Presentation.Entities.PredictionTiming, Tfl.Api.Presentation.Entities",
        "countdownServerAdjustment": "00:00:00.4088629",
        "source": "2017-06-15T14:08:50.854Z",
        "insert": "2017-06-17T13:43:37.619Z",
        "read": "2017-06-17T13:43:37.619Z",
        "sent": "2017-06-17T13:44:20Z",
        "received": "0001-01-01T00:00:00Z"
     }
 },
*/

@objc(TFLCDBusStop)
public class TFLCDBusStop: NSManagedObject {
    fileprivate static let loggingHandle  = OSLog(subsystem: TFLLogger.subsystem, category: TFLLogger.category.busStop.rawValue)
    private enum Identifiers : String {
        case naptanId = "naptanId"
        case stationNaptan = "stationNaptan"
        case commonName = "commonName"
        case latitude = "lat"
        case longitude = "lon"
        case stopType = "stopType"
        case stopLetter = "stopLetter"
        case towardsKeyValue = "Towards"
        case status = "status"
        case additionalProperties = "additionalProperties"
        case lines = "lines"
    }
    static func ==(lhs : TFLCDBusStop,rhs: TFLCDBusStop) -> (Bool) {
        return lhs.identifier == rhs.identifier
    }

    override public var debugDescription: String {
        var desc = ""
        self.managedObjectContext?.performAndWait {
            desc = "\n"+name + "[\(identifier)] towards " + (towards ?? "") + "status:\(status):\n"
        }
        return desc
    }
    
    func distance(to location: CLLocation) -> Double {
        return location.distance(from:coord.location)
    }
    
    
    var coord : CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(self.lat, self.long)
    }

    class func busStopEntity(with identifier: String,and managedObjectContext: NSManagedObjectContext,using completionBlock :@escaping (_ busStop : TFLCDBusStop?) -> () ) {
        let fetchRequest = NSFetchRequest<TFLCDBusStop>(entityName: String(describing: TFLCDBusStop.self))
        fetchRequest.fetchBatchSize = 1
        fetchRequest.returnsObjectsAsFaults = true
        fetchRequest.predicate = NSPredicate(format: "identifier = %@", identifier)
        managedObjectContext.perform {
            var busStop = (try? managedObjectContext.fetch(fetchRequest) )?.first

            if case .none = busStop {
                busStop = NSEntityDescription.insertNewObject(forEntityName: String(describing:self), into: managedObjectContext) as? TFLCDBusStop
                busStop?.identifier = identifier
            }
            completionBlock(busStop)
        }
    }

    class func busStop(with dictionary: [String: Any], and managedObjectContext: NSManagedObjectContext,using completionBlock : @escaping (_ busStop : TFLCDBusStop?) -> () ) {
        guard let identifier = dictionary[Identifiers.naptanId.rawValue] as? String,
            let stopType = dictionary[Identifiers.stopType.rawValue] as? String, stopType == "NaptanPublicBusCoachTram" else {
                completionBlock(nil)
                return
        }
        self.busStopEntity(with: identifier, and: managedObjectContext) { busStop in
            managedObjectContext.perform {
                if let busStop = busStop {
                    let stationIdentifier = dictionary[Identifiers.stationNaptan.rawValue] as? String ?? ""
                    let status = dictionary[Identifiers.status.rawValue] as? Bool ?? false
                    let name = dictionary[Identifiers.commonName.rawValue] as? String ?? ""
                    let long = dictionary[Identifiers.longitude.rawValue] as? Double ?? kCLLocationCoordinate2DInvalid.longitude
                    let lat = dictionary[Identifiers.latitude.rawValue] as? Double ?? kCLLocationCoordinate2DInvalid.latitude
                    let stopLetter = dictionary[Identifiers.stopLetter.rawValue] as? String ?? ""
                    var towards = ""
                    var lines : [String] = []
                    if let additionalProperties = dictionary[Identifiers.additionalProperties.rawValue] as? [[String:String]] {
                        let towardsDict = additionalProperties.first { $0["key"] ==  Identifiers.towardsKeyValue.rawValue }
                        if let towardsDict = towardsDict?["value"]  {
                            towards = towardsDict
                        }
                    }
                    if let linesDictList = dictionary[Identifiers.lines.rawValue] as? [[String:Any]] {
                        if let lineIdentifiers = (linesDictList.compactMap{ $0["id"] }) as? [String] {
                            lines = lineIdentifiers
                        }

                    }

                    if busStop.status != status { busStop.status = status }
                    if busStop.name != name && !name.isEmpty { busStop.name = name }
                    if busStop.long != long && long != kCLLocationCoordinate2DInvalid.longitude { busStop.long = long }
                    if busStop.lat != lat && lat != kCLLocationCoordinate2DInvalid.latitude { busStop.lat = lat }
                    if busStop.stopLetter != stopLetter && (!stopLetter.isEmpty || (busStop.stopLetter == .none))   { busStop.stopLetter = stopLetter }
                    if busStop.towards != towards && (!towards.isEmpty || (busStop.towards == .none)) { busStop.towards = towards }
                    if busStop.lines != lines && !lines.isEmpty { busStop.lines = lines }
                    if busStop.stationIdentifier != stationIdentifier && !stationIdentifier.isEmpty { busStop.stationIdentifier = stationIdentifier }
                }
                completionBlock(busStop)
            }
        }
    }

    class func busStops(with identifiers: [String],and managedObjectContext: NSManagedObjectContext) -> [TFLCDBusStop] {
        var sortedBusStops : [TFLCDBusStop] = []
        managedObjectContext.performAndWait{
            let fetchRequest = NSFetchRequest<TFLCDBusStop>(entityName: String(describing: TFLCDBusStop.self))
            let predicate = NSPredicate(format: "identifier in (%@)",identifiers)
            fetchRequest.predicate = predicate
            let busStops =  (try? managedObjectContext.fetch(fetchRequest)) ?? []
            let busStopsDict = Dictionary(grouping: busStops) { $0.identifier }
            sortedBusStops = identifiers.compactMap{ busStopsDict[$0]?.first }

        }
        return sortedBusStops
    }
    
    class func nearbyBusStops(with coordinate: CLLocationCoordinate2D, with radiusInMeter: Double = 350,and context: NSManagedObjectContext =  TFLBusStopStack.sharedDataStack.mainQueueManagedObjectContext,using completionBlock : @escaping ([TFLCDBusStop])->())  {
        
        // London : long=-0.252395&lat=51.506788
        // Latitude 1 Degree : 111.111 KM = 1/1111 Degree ≈ 100 m
        // Longitude 1 Degree : cos(51.506788)*111.111 = 0.3235612467* 111.111 = 35.9512136821 => 1/359.512136 Degree ≈ 100 m
        let factor = (radiusInMeter/100)
        let latOffset : Double =  factor/1111.11
        let longOffset : Double =  factor/359.512136
        let latLowerLimit = coordinate.latitude-latOffset
        let latUpperLimit = coordinate.latitude+latOffset
        let longLowerLimit = coordinate.longitude-longOffset
        let longUpperLimit = coordinate.longitude+longOffset
        let predicate = NSPredicate(format: "(long>=%f AND long<=%f) AND (lat>=%f AND lat <= %f) AND (status == YES)",longLowerLimit,longUpperLimit,latLowerLimit,latUpperLimit)
      
        let busStopFetchRequest = NSFetchRequest<TFLCDBusStop>(entityName: "TFLCDBusStop")
        busStopFetchRequest.returnsObjectsAsFaults = true
        busStopFetchRequest.includesSubentities = false
        busStopFetchRequest.predicate = predicate
        
        var busStops : [TFLCDBusStop] = []
        let currentLocation = coordinate.location
        let privateContext = TFLBusStopStack.sharedDataStack.privateQueueManagedObjectContext
        privateContext.perform  {
            TFLLogger.shared.signPostStart(osLog: TFLCDBusStop.loggingHandle , name: "nearbyBusStops coredata")
            if let stops =  try? privateContext.fetch(busStopFetchRequest) {
                TFLLogger.shared.signPostEnd(osLog: TFLCDBusStop.loggingHandle, name: "nearbyBusStops coredata")
                busStops = stops.map{ ($0.distance(to:currentLocation),$0) }
                    .filter{ $0.0 < radiusInMeter }
                    .sorted{ $0.0 < $1.0 }
                    .map{ $0.1 }
            }
            context.perform  {
                let importedStops = busStops.map{ context.object(with:$0.objectID) } as? [TFLCDBusStop] ?? []
                completionBlock(importedStops)
            }
        }
    }

    
}
