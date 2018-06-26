//
//  TFLCDLineRoute+CoreDataClass.swift
//  tflapp
//
//  Created by Frank Saar on 31/05/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//
//

import Foundation
import CoreData

@objc(TFLCDLineRoute)
public class TFLCDLineRoute: NSManagedObject {
    private enum Identifiers : String {
        case name = "name"
        case stations = "naptanIds"
        case serviceType = "serviceType"
    }
    class func routeEntity(with name: String,and managedObjectContext: NSManagedObjectContext,using completionBlock :@escaping (_ lineInfo : TFLCDLineRoute?) -> () ) {
        let fetchRequest = NSFetchRequest<TFLCDLineRoute>(entityName: String(describing: self))
        fetchRequest.fetchBatchSize = 1
        fetchRequest.returnsObjectsAsFaults = true
        fetchRequest.predicate = NSPredicate(format: "name = %@", name)
        managedObjectContext.perform {
            var route = (try? managedObjectContext.fetch(fetchRequest) )?.first
            
            if case .none = route {
                route = NSEntityDescription.insertNewObject(forEntityName: String(describing:self), into: managedObjectContext) as? TFLCDLineRoute
                route?.name = name
            }
            completionBlock(route)
        }
    }
    
    class func route(with dictionary: [String: Any], and managedObjectContext: NSManagedObjectContext,using completionBlock : @escaping (_ route : TFLCDLineRoute?) -> () ) {
        guard let name = dictionary[Identifiers.name.rawValue] as? String else {
            completionBlock(nil)
            return
        }
        self.routeEntity(with: name, and: managedObjectContext) { route in
            managedObjectContext.perform {
                if let route = route {
                    let serviceType = dictionary[Identifiers.serviceType.rawValue] as? String ?? ""
                    let stations = dictionary[Identifiers.stations.rawValue] as? [String] ?? []
                    if route.stations != stations && (!stations.isEmpty || (route.stations == .none)) { route.stations = stations   }
                    if route.serviceType != serviceType && (!serviceType.isEmpty || (route.serviceType == .none)) { route.serviceType = serviceType   }
                }
                completionBlock(route)
            }
        }
    }
}
