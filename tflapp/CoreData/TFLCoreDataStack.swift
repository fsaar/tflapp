import Foundation
import CoreData

@objc public final class TFLCoreDataStack : NSObject {
    
    static let sharedDataStack = TFLCoreDataStack()
    
    lazy public fileprivate(set) var privateQueueManagedObjectContext : NSManagedObjectContext =  {
        let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        context.persistentStoreCoordinator = self.storeCoordinator
        return context
        
    }()

    fileprivate var storeCoordinator : NSPersistentStoreCoordinator

    fileprivate var backgroundNotificationObserver : TFLNotificationObserver?
    
    override init() {
        func initCoreData(_ coordinator : NSPersistentStoreCoordinator) -> Bool {
            let storeURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!.appendingPathComponent("TFLBusStops.sqlite")
            print(storeURL)
            let dict : [String : Any] = [ NSPersistentStoreFileProtectionKey : FileProtectionType.complete as Any , NSSQLitePragmasOption : ["journal_mode" : "DELETE"],
                                                NSMigratePersistentStoresAutomaticallyOption : true,
                                                NSInferMappingModelAutomaticallyOption : true]
            guard let _ = try? coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: dict) else {
                return false
            }
            return true
        }

        
        let models = NSManagedObjectModel.mergedModel(from: nil)!
        storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: models)
        _ = initCoreData(storeCoordinator)
        
        super.init()
        self.backgroundNotificationObserver = TFLNotificationObserver(notification: NSNotification.Name.UIApplicationDidEnterBackground.rawValue, handlerBlock: { [weak self] (notification) in
            self?.privateQueueManagedObjectContext.performAndWait {
                _ = try? self?.privateQueueManagedObjectContext.save()
            }
            });
    }
}


