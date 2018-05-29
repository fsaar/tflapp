//
//  TFLCDLineInfo+CoreDataClass.swift
//  tflapp
//
//  Created by Frank Saar on 28/05/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//
//

import Foundation
import CoreData

@objc(TFLCDLineInfo)
public class TFLCDLineInfo: NSManagedObject {
    private enum Identifiers : String {
        case lineId = "lineId"
        case stations = "stations"
    }
    class func lineInfoEntity(with identifier: String,and managedObjectContext: NSManagedObjectContext,using completionBlock :@escaping (_ lineInfo : TFLCDLineInfo?) -> () ) {
        let fetchRequest = NSFetchRequest<TFLCDLineInfo>(entityName: String(describing: self))
        fetchRequest.fetchBatchSize = 1
        fetchRequest.returnsObjectsAsFaults = true
        fetchRequest.predicate = NSPredicate(format: "identifier = %@", identifier)
        managedObjectContext.perform {
            var lineInfo = (try? managedObjectContext.fetch(fetchRequest) )?.first
            
            if case .none = lineInfo {
                lineInfo = NSEntityDescription.insertNewObject(forEntityName: String(describing:self), into: managedObjectContext) as? TFLCDLineInfo
                lineInfo?.identifier = identifier
            }
            completionBlock(lineInfo)
        }
    }
    
    class func lineInfo(with dictionary: [String: Any], and managedObjectContext: NSManagedObjectContext,using completionBlock : @escaping (_ lineInfo : TFLCDLineInfo?) -> () ) {
        guard let identifier = dictionary[Identifiers.lineId.rawValue] as? String else {
            completionBlock(nil)
            return
        }
        self.lineInfoEntity(with: identifier, and: managedObjectContext) { lineInfo in
            managedObjectContext.perform {
                if let lineInfo = lineInfo {
                    if let stationDictList = dictionary[Identifiers.stations.rawValue] as? [[String:Any]] {
                        let group = DispatchGroup()
                        for dict in  stationDictList {
                            group.enter()
                            TFLCDStation.station(with: dict, and: managedObjectContext) { station in
                                if let station = station {
                                    lineInfo.addToStations(station)
                                }
                                group.leave()
                            }
                        }
                        group.notify(queue: .global()) {
                            completionBlock(lineInfo)
                        }
                    }
                    else {
                        completionBlock(lineInfo)
                    }
                }
            }
        }
    }
    
    class func lineInfo(with identifier: String,and managedObjectContext: NSManagedObjectContext) -> TFLCDLineInfo? {
        var lineInfo : TFLCDLineInfo?
        managedObjectContext.performAndWait {
            let fetchRequest = NSFetchRequest<TFLCDLineInfo>(entityName: String(describing: TFLCDLineInfo.self))
            let predicate = NSPredicate(format: "identifier == %@",identifier)
            fetchRequest.predicate = predicate
            lineInfo =  (try? managedObjectContext.fetch(fetchRequest))?.first
        }
        return lineInfo
    }
}
