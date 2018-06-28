import Foundation
import CoreData
import Crashlytics
import CoreLocation

private let dbFileName  = URL(string:"TFLBusStops.sqlite")
private let groupID =  "group.tflwidgetSharingData"

@objc public final class TFLBusStopStack : NSObject {

    static let sharedDataStack = TFLBusStopStack()

    lazy var busStopFetchRequest : NSFetchRequest<TFLCDBusStop> = {
        let fetchRequest = NSFetchRequest<TFLCDBusStop>(entityName: "TFLCDBusStop")
        fetchRequest.returnsObjectsAsFaults = true
        fetchRequest.shouldRefreshRefetchedObjects = true
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
            Crashlytics.notify()
            if cleanUpCoreData(storeCoordinator) {
                Crashlytics.notify()
                if !initCoreData(storeCoordinator) {
                    Crashlytics.log("Can't recover from Core Data initialisation")
                    fatalError("Can't recover from Core Data initialisation")
                }
            }
            else {
                Crashlytics.log("Can't recover from Core Data initialisation")
                fatalError("Can't recover from Core Data initialisation")
            }
        }

        super.init()

    }

    func nearbyBusStops(with coordinate: CLLocationCoordinate2D, with radiusInMeter: Double = 350,and context: NSManagedObjectContext =  TFLBusStopStack.sharedDataStack.mainQueueManagedObjectContext,using completionBlock : @escaping ([TFLCDBusStop])->())  {
        

        // London : long=-0.252395&lat=51.506788
        // Latitude 1 Degree : 111.111 KM = 1/100 Degree => 1.11111 KM => 1/200 Degree ≈ 550m
        // Longitude 1 Degree : cos(51.506788)*111.111 = 0.3235612467* 111.111 = 35.9512136821 => 1/70 Degree ≈ 500 m

        let latDivisor  = 111.111 / radiusInMeter
        let longDivisor = 0.3235612467 *  111.111 / radiusInMeter
        let latOffset : Double =  1/latDivisor       // 1/200
        let longOffset : Double =  1/longDivisor    // 1/70
        let latLowerLimit = coordinate.latitude-latOffset
        let latUpperLimit = coordinate.latitude+latOffset
        let longLowerLimit = coordinate.longitude-longOffset
        let longUpperLimit = coordinate.longitude+longOffset

        let predicate = NSPredicate(format: "(long>=%f AND long<=%f) AND (lat>=%f AND lat <= %f) AND (status == YES)",longLowerLimit,longUpperLimit,latLowerLimit,latUpperLimit)
        self.busStopFetchRequest.predicate = predicate
        var busStops : [TFLCDBusStop] = []
        let currentLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        TFLBusStopStack.sharedDataStack.privateQueueManagedObjectContext.perform  {
            if let stops =  try? context.fetch(self.busStopFetchRequest) {
                busStops = stops.filter { currentLocation.distance(from: CLLocation(latitude: $0.lat, longitude: $0.long) ) < radiusInMeter }
            }
            context.perform  {
                let importedStops = busStops.map { context.object(with:$0.objectID) } as? [TFLCDBusStop] ?? []
                completionBlock(importedStops)
            }
        }
    }
}
