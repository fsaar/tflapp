import Foundation
import UIKit
import CoreData
import CoreLocation
import os.signpost

private let dbFileName  = URL(string:"TFLBusStops.sqlite")
private let groupID =  "group.tflwidgetSharingData"

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

    fileprivate var storeCoordinator : NSPersistentStoreCoordinator?

    fileprivate override init() {
        super.init()

        guard let coordinator = initCoreData() else {
            fatalError("Can't recover from Core Data initialisation")
        }
        storeCoordinator = coordinator
    }
}


fileprivate extension TFLBusStopStack {
    var destinationURL : URL? {
        guard let dbFullFileName = dbFileName?.path,let destinationURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID)?.appendingPathComponent(dbFullFileName) else {
            return nil
        }
        return destinationURL
    }
    
    var sourceURL : URL? {
        guard let path = dbFileName?.deletingPathExtension().path,let ext = dbFileName?.pathExtension,
            let sourceURL = Bundle.main.url(forResource: path, withExtension: ext) else {
                return nil
        }
        return sourceURL
    }
    
    func initCoreData() -> NSPersistentStoreCoordinator? {
        deleteOldPersistentStoreIfNeedBe()
        let models = NSManagedObjectModel.mergedModel(from: nil)!
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: models)
        
        guard !initCoreData(with: coordinator) else {
            return coordinator
        }
        guard cleanUpCoreData(coordinator) else {
            return nil
        }
        let coordinator2 = NSPersistentStoreCoordinator(managedObjectModel: models)
        guard !initCoreData(with: coordinator2) else {
            return coordinator2
        }
        return nil
    }
    
    func cleanUpCoreData(_ coordinator : NSPersistentStoreCoordinator) -> Bool{
        guard let toURL = self.destinationURL else {
            return false
        }
        if let persistentStore = coordinator.persistentStores.first {
            _ = try? coordinator .remove(persistentStore)
        }
        guard let _ = try? FileManager.default.removeItem(at: toURL) else {
            return false
        }
        return true
    }
    
    func storeUUID(of store : NSPersistentStore) throws -> String {
        try store.loadMetadata()
        let metaData = store.metadata as [String:Any]
        let version = metaData[NSStoreUUIDKey] as? String ?? ""
        return version
    }
    
    func deleteOldPersistentStoreIfNeedBe()  {
        guard let toURL = self.destinationURL,let fromURL = self.sourceURL  else {
                return
        }
        if !FileManager.default.fileExists(atPath: toURL.path) {
            return
        }
        
        do {
            let dict1 : [String : Any] = [ NSMigratePersistentStoresAutomaticallyOption : true,
                                           NSInferMappingModelAutomaticallyOption : true]
            let dict2 : [String : Any] = [ NSMigratePersistentStoresAutomaticallyOption : true,
                                           NSInferMappingModelAutomaticallyOption : true,
                                           NSReadOnlyPersistentStoreOption : true]
            let models = NSManagedObjectModel.mergedModel(from: nil)!
            let coordinator1 = NSPersistentStoreCoordinator(managedObjectModel: models)
            let coordinator2 = NSPersistentStoreCoordinator(managedObjectModel: models)
            try coordinator1.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: toURL, options: dict1)
            try coordinator2.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: fromURL, options: dict2)
            let version1 = try storeUUID(of: coordinator1.persistentStores[0])
            let version2 = try storeUUID(of: coordinator2.persistentStores[0])
            guard version1 != version2 else {
                return
            }
            try FileManager.default.removeItem(at: toURL)
        }
        catch {
            return
        }
    }
    
    
    func initCoreData(with coordinator : NSPersistentStoreCoordinator) -> Bool {
        
        guard let toURL = self.destinationURL,let fromURL = self.sourceURL  else {
            return false
        }
        
        if !FileManager.default.fileExists(atPath: toURL.path) {
            _ = try? FileManager.default.copyItem(at: fromURL, to: toURL)
        }
        let dict : [String : Any] = [ NSMigratePersistentStoresAutomaticallyOption : true,
                                      NSInferMappingModelAutomaticallyOption : true]
        guard let _ = try? coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: toURL, options: dict) else {
            return false
        }
        return true
    }
}
