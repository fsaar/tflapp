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

    fileprivate override init() {

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
        
        
        func deleteOldPersistentStoreIfNeedBe()  {
            
            guard let dbFullFileName = dbFileName?.path, let path = dbFileName?.deletingPathExtension().path,let ext = dbFileName?.pathExtension,
                let sourceURL = Bundle.main.url(forResource: path, withExtension: ext),
                let destinationURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID)?.appendingPathComponent(dbFullFileName)
                else {
                    return
            }
            if !FileManager.default.fileExists(atPath: destinationURL.path) {
                return
            }

            do {
                let dict : [String : Any] = [ NSMigratePersistentStoresAutomaticallyOption : true,
                                              NSInferMappingModelAutomaticallyOption : true]
                
                let models = NSManagedObjectModel.mergedModel(from: nil)!
                let coordinator = NSPersistentStoreCoordinator(managedObjectModel: models)
                try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: destinationURL, options: dict)
                try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: sourceURL, options: dict)
                guard coordinator.persistentStores.count == 2 else {
                    return
                }
                let store1 = coordinator.persistentStores[0]
                let store2 = coordinator.persistentStores[1]
                try store1.loadMetadata()
                try store2.loadMetadata()
                let metaData1 = store1.metadata as [String:Any]
                let metaData2 = store2.metadata as [String:Any]
                let version1 = metaData1[NSStoreUUIDKey] as? String ?? ""
                let version2 = metaData2[NSStoreUUIDKey] as? String ?? ""
                guard version1 != version2 else {
                   return
                }
                try FileManager.default.removeItem(at: destinationURL)
            }
            catch {
                return
            }
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

        deleteOldPersistentStoreIfNeedBe()
        let models = NSManagedObjectModel.mergedModel(from: nil)!
        storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: models)
        if !initCoreData(storeCoordinator) {
   
            if cleanUpCoreData(storeCoordinator) {
                storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: models)
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
    
    
}


fileprivate extension TFLBusStopStack {
    
}
