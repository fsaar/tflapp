import Foundation
import CoreData
import CoreLocation

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
    "timestamp": "2017-06-17T13:44:20Z",
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
 }, {
    "$type": "Tfl.Api.Presentation.Entities.Prediction, Tfl.Api.Presentation.Entities",
    "id": "1095744434",
    "operationType": 1,
    "vehicleId": "LK17AFA",
    "naptanId": "490015185H",
    "stationName": "Trocadero / Haymarket",
    "lineId": "19",
    "lineName": "19",
    "platformName": "H",
    "direction": "inbound",
    "bearing": "21",
    "destinationNaptanId": "",
    "destinationName": "Finsbury Park Station",
    "timestamp": "2017-06-17T13:44:20Z",
    "timeToStation": 863,
    "currentLocation": "",
    "towards": "Holborn or Warren Street Station",
    "expectedArrival": "2017-06-17T13:58:43Z",
    "timeToLive": "2017-06-17T13:59:13Z",
    "modeName": "bus",
    "timing": {
        "$type": "Tfl.Api.Presentation.Entities.PredictionTiming, Tfl.Api.Presentation.Entities",
        "countdownServerAdjustment": "00:00:00.4921822",
        "source": "2017-06-15T14:08:50.854Z",
        "insert": "2017-06-17T13:43:37.619Z",
        "read": "2017-06-17T13:43:37.619Z",
        "sent": "2017-06-17T13:44:20Z",
        "received": "0001-01-01T00:00:00Z"
     }
 }]
*/

@objc public class TFLCDBusStop: NSManagedObject {
    private enum Identifiers : String {
        case naptanId = "naptanId"
        case commonName = "commonName"
        case latitude = "lat"
        case longitude = "lon"
        case stopType = "stopType"
        case stopLetter = "stopLetter"
        case towardsKeyValue = "Towards"
        case status = "status"
        case additionalProperties = "additionalProperties"
    }
    static func ==(lhs : TFLCDBusStop,rhs: TFLCDBusStop) -> (Bool) {
        return lhs.identifier == lhs.identifier
    }
    
    override public var debugDescription: String {
        return "\n"+name + "[\(identifier)] towards " + towards + "status:\(status):\n"
    }

    var coord : CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(self.lat, self.long)
    }
    
    class func busStopEntity(with identifier: String,and managedObjectContext: NSManagedObjectContext) -> (TFLCDBusStop?) {
        let fetchRequest = NSFetchRequest<TFLCDBusStop>(entityName: String(describing: TFLCDBusStop.self))
        fetchRequest.fetchBatchSize = 1
        fetchRequest.returnsObjectsAsFaults = true
        fetchRequest.predicate = NSPredicate(format: "identifier = %@", identifier)
        var busStop : TFLCDBusStop?
        managedObjectContext.performAndWait {
            busStop = (try? managedObjectContext.fetch(fetchRequest) )?.first
        }
        
        if case .none = busStop {
            busStop = NSEntityDescription.insertNewObject(forEntityName: String(describing:self), into: managedObjectContext) as? TFLCDBusStop
            busStop?.identifier = identifier
        }
        return busStop
    }
    
    class func busStop(with dictionary: [String: Any], and managedObjectContext: NSManagedObjectContext) -> (TFLCDBusStop?) {
        guard let identifier = dictionary[Identifiers.naptanId.rawValue] as? String,
        let stopType = dictionary[Identifiers.stopType.rawValue] as? String, stopType == "NaptanPublicBusCoachTram" else {
            return nil
        }
        guard  let busStop = self.busStopEntity(with: identifier, and: managedObjectContext) else {
            return nil
        }
      
        let status = dictionary[Identifiers.status.rawValue] as? Bool ?? false
        let name = dictionary[Identifiers.commonName.rawValue] as? String ?? ""
        let long = dictionary[Identifiers.longitude.rawValue] as? Double ?? kCLLocationCoordinate2DInvalid.longitude
        let lat = dictionary[Identifiers.latitude.rawValue] as? Double ?? kCLLocationCoordinate2DInvalid.latitude
        let stopLetter = dictionary[Identifiers.stopLetter.rawValue] as? String ?? ""
        var towards = ""
        if let additionalProperties = dictionary[Identifiers.additionalProperties.rawValue] as? [[String:String]] {
            let towardsDict = additionalProperties.filter { $0["key"] ==  Identifiers.towardsKeyValue.rawValue }.first
            if let towardsDict = towardsDict?["value"]  {
                towards = towardsDict
            }
        }

        if busStop.status != status { busStop.status = status }
        if busStop.name != name && (!name.isEmpty || (busStop.name == .none)) { busStop.name = name }
        if busStop.long != long && long != kCLLocationCoordinate2DInvalid.longitude { busStop.long = long }
        if busStop.lat != lat && lat != kCLLocationCoordinate2DInvalid.latitude { busStop.lat = lat }
        if busStop.stopLetter != stopLetter && (!stopLetter.isEmpty || (busStop.stopLetter == .none))   { busStop.stopLetter = stopLetter }
        if busStop.towards != towards && (!towards.isEmpty || (busStop.towards == .none)) { busStop.towards = towards }
        return busStop
    }
}
