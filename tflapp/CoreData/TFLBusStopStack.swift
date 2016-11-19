import Foundation
import CoreData
import Crashlytics

@objc public final class TFLBusStopStack : NSObject {
    
    static let sharedDataStack = TFLBusStopStack()
    
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

    fileprivate var backgroundNotificationObserver : TFLNotificationObserver?
    
    override init() {
        func cleanUpCoreData(_ coordinator : NSPersistentStoreCoordinator) -> Bool{
            guard let destinationStoreURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last?.appendingPathComponent("TFLBusStops.sqlite") else {
                return false
            }
            if let persistentStore = coordinator.persistentStores.first {
                _ = try? coordinator .remove(persistentStore)
            }
            guard let _ = try? FileManager.default.removeItem(at: destinationStoreURL) else {
                return false
                
            }
            
            return true
        }

        
        
        func initCoreData(_ coordinator : NSPersistentStoreCoordinator) -> Bool {
            guard let destinationStoreURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last?.appendingPathComponent("TFLBusStops.sqlite"),
                let sourceStoreURL = Bundle.main.url(forResource: "TFLBusStops", withExtension: "sqlite") else {
                return false
            }

            if !FileManager.default.fileExists(atPath: destinationStoreURL.path) {
                _ = try? FileManager.default.copyItem(at: sourceStoreURL, to: destinationStoreURL)
            }
            let dict : [String : Any] = [ NSPersistentStoreFileProtectionKey : FileProtectionType.complete as Any  ,
                                                NSMigratePersistentStoresAutomaticallyOption : true,
                                                NSInferMappingModelAutomaticallyOption : true]
            guard let _ = try? coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: destinationStoreURL, options: dict) else {
                return false
            }
            return true
        }


        let models = NSManagedObjectModel.mergedModel(from: nil)!
        storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: models)
        _ = initCoreData(storeCoordinator)
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
        
        self.backgroundNotificationObserver = TFLNotificationObserver(notification: NSNotification.Name.UIApplicationDidEnterBackground.rawValue, handlerBlock: { [weak self] (notification) in
            self?.privateQueueManagedObjectContext.performAndWait {
                _ = try? self?.privateQueueManagedObjectContext.save()
            }
        });
    }
}


