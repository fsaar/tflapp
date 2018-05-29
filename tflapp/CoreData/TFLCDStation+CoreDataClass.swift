//
//  TFLCDStation+CoreDataClass.swift
//  tflapp
//
//  Created by Frank Saar on 29/05/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//
//

import Foundation
import CoreData
import CoreLocation


@objc(TFLCDStation)
public class TFLCDStation: NSManagedObject {
    private enum Identifiers : String {
        case identifer = "id"
        case latitude = "lat"
        case longitude = "lon"
        case name = "name"
    }
    class func stationEntity(with identifier: String,and managedObjectContext: NSManagedObjectContext,using completionBlock :@escaping (_ busStop : TFLCDStation?) -> () ) {
        let fetchRequest = NSFetchRequest<TFLCDStation>(entityName: String(describing: TFLCDStation.self))
        fetchRequest.fetchBatchSize = 1
        fetchRequest.returnsObjectsAsFaults = true
        fetchRequest.predicate = NSPredicate(format: "identifier = %@", identifier)
        managedObjectContext.perform {
            var station = (try? managedObjectContext.fetch(fetchRequest) )?.first
            
            if case .none = station {
                station = NSEntityDescription.insertNewObject(forEntityName: String(describing:self), into: managedObjectContext) as? TFLCDStation
                station?.identifier = identifier
            }
            completionBlock(station)
        }
    }
    
    class func station(with dictionary: [String: Any], and managedObjectContext: NSManagedObjectContext,using completionBlock : @escaping (_ statopm : TFLCDStation?) -> () ) {
        guard let identifier = dictionary[Identifiers.identifer.rawValue] as? String else {
                completionBlock(nil)
                return
        }
        self.stationEntity(with: identifier, and: managedObjectContext) { station in
            managedObjectContext.perform {
                if let station = station {
                    let name = dictionary[Identifiers.name.rawValue] as? String ?? ""
                    let long = dictionary[Identifiers.longitude.rawValue] as? Double ?? kCLLocationCoordinate2DInvalid.longitude
                    let lat = dictionary[Identifiers.latitude.rawValue] as? Double ?? kCLLocationCoordinate2DInvalid.latitude
                    
                    if station.name != name && (!name.isEmpty || (station.name == .none)) { station.name = name }
                    if station.long != long && long != kCLLocationCoordinate2DInvalid.longitude { station.long = long }
                    if station.lat != lat && lat != kCLLocationCoordinate2DInvalid.latitude { station.lat = lat }
                    
                }
                completionBlock(station)
            }
        }
    }
}
