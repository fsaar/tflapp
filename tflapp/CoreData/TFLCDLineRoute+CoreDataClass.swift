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
import MapKit


@objc(TFLCDLineRoute)
public class TFLCDLineRoute: NSManagedObject {
    static var polyLineDict = PolylineDict()
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
                    print("retrieving route \(name)")
                    let serviceType = dictionary[Identifiers.serviceType.rawValue] as? String ?? ""
                    let stations = dictionary[Identifiers.stations.rawValue] as? [String] ?? []

                    if route.stations != stations && (!stations.isEmpty || (route.stations == .none)) { route.stations = stations }
                    if route.serviceType != serviceType && (!serviceType.isEmpty || (route.serviceType == .none)) { route.serviceType = serviceType }
                    #if DEBUG
                    
                    let polyLine = PolyLine(precision: 5)
                    let key = stations.sorted(by:<).joined(separator: "-")
                    let busStops = TFLCDBusStop.busStops(with: stations, and: managedObjectContext)
                    let coords = busStops.map { CLLocationCoordinate2DMake($0.lat, $0.long) }.filter { $0.isValid }
                    if let polyLineString = self.polyLineDict[key] {
                        print("reusing polyline")
                        route.polyline  = polyLineString
                        completionBlock(route)
                        return
                    }
                    
                    hiresRoutePolyline(polyLine, with: coords) { polyLineString in
                        managedObjectContext.perform {
                            route.polyline  = polyLineString
                            polyLineDict[key] = polyLineString
                            completionBlock(route)
                        }
                    }
                    #else
                        completionBlock(route)
                    #endif
                   
                }
                else {
                    completionBlock(route)
                }
            }
        }
    }
}

fileprivate extension TFLCDLineRoute {
    
    class func hiresRoutePolyline(_ polyLine : PolyLine,with coords : [CLLocationCoordinate2D], using completionBlock: @escaping (String?) -> Void) {
        guard !coords.isEmpty else {
            completionBlock(nil)
            return
        }
        let session = URLSession(configuration: URLSessionConfiguration.default)
        
        coords.googleHiresRoutes(with: session) { hiresCoords in
            let polyLineString = polyLine.encode(coordinates: hiresCoords)
            let valid = polyLine.verify(polyLine: polyLineString ?? "", coordinates: hiresCoords)
            precondition(valid)
            completionBlock(polyLineString)
        }
    }
}
