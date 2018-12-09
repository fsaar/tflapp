import Foundation
import UIKit
import CoreData
import CoreLocation
import os.signpost

private let dbFileName  = URL(string:"TFLBusStops.sqlite")
private let groupID =  "group.tflwidgetSharingData"

@objc public final class TFLBusStopStack : NSObject {
    fileprivate static let loggingHandle  = OSLog(subsystem: TFLLogger.subsystem, category: TFLLogger.category.coredata.rawValue)

    static let sharedDataStack = TFLBusStopStack()

    let busStopFetchRequest : NSFetchRequest<TFLCDBusStop> = {
        let fetchRequest = NSFetchRequest<TFLCDBusStop>(entityName: "TFLCDBusStop")
        fetchRequest.returnsObjectsAsFaults = true
        fetchRequest.includesSubentities = false
        return fetchRequest
    }()

    lazy public fileprivate(set) var mainQueueManagedObjectContext : NSManagedObjectContext = {
        let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        context.parent = self.privateQueueManagedObjectContext
        return context
    }()

    lazy public fileprivate(set) var privateQueueManagedObjectContext : NSManagedObjectContext =  {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = self.storeCoordinator
        return context

    }()

    fileprivate var storeCoordinator : NSPersistentStoreCoordinator

    override init() {

        func cleanUpCoreData(_ coordinator : NSPersistentStoreCoordinator) -> Bool{
            guard let dbFullFileName = dbFileName?.path,let destinationURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID)?.appendingPathComponent(dbFullFileName) else {
                return false
            }
            if let persistentStore = coordinator.persistentStores.first {
                _ = try? coordinator .remove(persistentStore)
            }
            guard let _ = try? FileManager.default.removeItem(at: destinationURL) else {
                return false

            }

            return true
        }



        func initCoreData(_ coordinator : NSPersistentStoreCoordinator) -> Bool {

            guard let dbFullFileName = dbFileName?.path, let path = dbFileName?.deletingPathExtension().path,let ext = dbFileName?.pathExtension,
                let sourceURL = Bundle.main.url(forResource: path, withExtension: ext),
                let destinationURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID)?.appendingPathComponent(dbFullFileName)
            else {
                return false
            }

            if !FileManager.default.fileExists(atPath: destinationURL.path) {
                _ = try? FileManager.default.copyItem(at: sourceURL, to: destinationURL)
            }
            let dict : [String : Any] = [ NSMigratePersistentStoresAutomaticallyOption : true,
                                                NSInferMappingModelAutomaticallyOption : true]
            guard let _ = try? coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: destinationURL, options: dict) else {
                return false
            }
            return true
        }


        let models = NSManagedObjectModel.mergedModel(from: nil)!
        storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: models)
        if !initCoreData(storeCoordinator) {
   
            if cleanUpCoreData(storeCoordinator) {
            
                if !initCoreData(storeCoordinator) {
           
                    fatalError("Can't recover from Core Data initialisation")
                }
            }
            else {
            
                fatalError("Can't recover from Core Data initialisation")
            }
        }

        super.init()

    }
    
    func nearbyBusStops(with coordinate: CLLocationCoordinate2D, with radiusInMeter: Double = 350,and context: NSManagedObjectContext =  TFLBusStopStack.sharedDataStack.mainQueueManagedObjectContext,using completionBlock : @escaping ([TFLCDBusStop])->())  {
        
        self.busStopFetchRequest.predicate = predicate(with: coordinate, and: radiusInMeter)
        var busStops : [TFLCDBusStop] = []
        let currentLocation = coordinate.location
        let privateContext = TFLBusStopStack.sharedDataStack.privateQueueManagedObjectContext
        privateContext.perform  {
            TFLLogger.shared.signPostStart(osLog: TFLBusStopStack.loggingHandle , name: "nearbyBusStops coredata")
            if let stops =  try? privateContext.fetch(self.busStopFetchRequest) {
                TFLLogger.shared.signPostEnd(osLog: TFLBusStopStack.loggingHandle, name: "nearbyBusStops coredata")
                busStops = stops.map { ($0.distance(to:currentLocation),$0) }
                                .filter { $0.0 < radiusInMeter }
                                .sorted { $0.0 < $1.0 }
                                .map { $0.1 }
            }
            context.perform  {
                let importedStops = busStops.map { context.object(with:$0.objectID) } as? [TFLCDBusStop] ?? []
                completionBlock(importedStops)
            }
        }
    }
}


fileprivate extension TFLBusStopStack {
    func predicate(with coordinate : CLLocationCoordinate2D, and radiusInMeter: Double) -> NSPredicate {
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
        return predicate
    }
}
