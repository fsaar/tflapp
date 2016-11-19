import Foundation
import CoreData
import CoreLocation


@objc(TFLCDBusStop)
public class TFLCDBusStop: NSManagedObject {
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
        if busStop.name != name && !name.isEmpty { busStop.name = name }
        if busStop.long != long && long != kCLLocationCoordinate2DInvalid.longitude { busStop.long = long }
        if busStop.lat != lat && lat != kCLLocationCoordinate2DInvalid.latitude { busStop.lat = lat }
        if busStop.stopLetter != stopLetter && !stopLetter.isEmpty { busStop.stopLetter = stopLetter }
        if busStop.towards != towards && !towards.isEmpty { busStop.towards = towards }
        return busStop
    }
}
