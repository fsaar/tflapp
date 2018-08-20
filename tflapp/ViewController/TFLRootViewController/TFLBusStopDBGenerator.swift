//
//  TFLBusStopDBGenerator.swift
//  tflapp
//
//  Created by Frank Saar on 04/08/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//

import Foundation
import CoreData

class TFLBusStopDBGenerator {
    // MARK: DataBase Generation
    fileprivate let tflClient = TFLClient()
    
    func loadLineStations() {
        self.linesFromBusStops { [weak self] lines in
            self?.load(lines: Array(lines), index: 0) {
                let context = TFLCoreDataStack.sharedDataStack.privateQueueManagedObjectContext
                context.performAndWait {
                    try? context.save()
                }
            }
        }
    }
    
    func linesFromBusStops(using completionBlock : ((_ lines : Set<String>) -> Void )?)  {
        var lines : Set<String> = []
        let context = TFLCoreDataStack.sharedDataStack.privateQueueManagedObjectContext
        let fetchRequest = NSFetchRequest<TFLCDBusStop>(entityName:String(describing: TFLCDBusStop.self))
        fetchRequest.includesSubentities = false
        fetchRequest.includesPropertyValues = false
        fetchRequest.propertiesToFetch = ["lines"]
        context.perform {
            if let stops = try? context.fetch(fetchRequest) as [TFLCDBusStop] {
                let lineList = stops.reduce([]) { sum,stop in
                    sum + (stop.lines ?? [])
                }
                lines = Set(lineList)
                completionBlock?(lines)
            }
        }
    }
    func load(lines : [String],index : Int = 0,using completionBlock: (()->())? = nil) {
        guard index < lines.count else {
            completionBlock?()
            return
        }
        let line = lines[index]
        print("\(index). \(line)")
        self.tflClient.lineStationInfo(for: line) { [weak self] _,_ in
            self?.load(lines: lines, index: index+1,using:completionBlock)
        }
    }
    
    // MARK: DataBase Generation (BusStops)
    
    func loadBusStops(of page: UInt = 0,using completionBlock: (()->())?) {
        self.tflClient.busStops(with: page) { [weak self] busStops,_ in
            guard let busStops = busStops, !busStops.isEmpty else {
                completionBlock?()
                return
            }
            print (page)
            self?.loadBusStops(of: page+1,using:completionBlock)
            let context = TFLCoreDataStack.sharedDataStack.privateQueueManagedObjectContext
            context.perform {
                try? context.save()
            }
        }
    }
}
