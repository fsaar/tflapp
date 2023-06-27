//
//  TFLBusStopDBGenerator.swift
//  tflapp
//
//  Created by Frank Saar on 04/08/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//

import Foundation
import SwiftData
import OSLog

class TFLBusStopDBGenerator {
    fileprivate let logger : Logger =  {
        let handle = Logger(subsystem: TFLLogger.subsystem, category: TFLLogger.category.databasegeneration.rawValue)
        return handle
    }()
    //
    // MARK: DataBase Generation
    //
   
    fileprivate let tflClient = TFLClient()
//    func loadLineStations() {
//        self.linesFromBusStops { [weak self] lines in
//            self?.load(lines: Array(lines), index: 0) {
//                let context = TFLCoreDataStack.sharedDataStack.privateQueueManagedObjectContext
//                context.performAndWait {
//                    try? context.save()
//                    print("Done !!")
//                }
//            }
//        }
//    }
//    
//    func linesFromBusStops(using completionBlock : ((_ lines : Set<String>) -> Void )?)  {
//        var lines : Set<String> = []
//        let context = TFLCoreDataStack.sharedDataStack.privateQueueManagedObjectContext
//        let fetchRequest = NSFetchRequest<TFLCDBusStop>(entityName:String(describing: TFLCDBusStop.self))
//        fetchRequest.includesSubentities = false
//        fetchRequest.includesPropertyValues = false
//        fetchRequest.propertiesToFetch = ["lines"]
//        context.perform {
//            if let stops = try? context.fetch(fetchRequest) as [TFLCDBusStop] {
//                let lineList = stops.reduce([]) { sum,stop in
//                    sum + (stop.lines ?? [])
//                }
//                lines = Set(lineList)
//                completionBlock?(lines)
//            }
//        }
//    }
    
//    func load(lines : [String],index : Int = 0,using completionBlock: (()->())? = nil) {
//        guard index < lines.count else {
//            completionBlock?()
//            return
//        }
//        let line = lines[index]
//        print("[\(index+1) / \(lines.count)]. Line:\(line)")
//        self.tflClient.lineStationInfo(for: line,context: TFLCoreDataStack.sharedDataStack.privateQueueManagedObjectContext) { [weak self] _,_ in
//            self?.load(lines: lines, index: index+1,using:completionBlock)
//        }
//    }
    
    //
    // MARK: DataBase Generation (BusStops)
    //
    func loadBusStops()  async throws {
      
        let container =  SwiftDataStack.shared.container
        let modelContext = ModelContext(container)
        var page = 0
        var keepLoading = true
        let stepSize = 10
        var totalCount = 0
        while keepLoading {
            self.logger.log("\(#function) Start: \(Date())  \(page..<(page+stepSize))")
            let busStops = await loadBusStopInBulk(of: page..<(page+stepSize))
            self.logger.log("\(#function) Stop: \(Date())  \(page..<(page+stepSize))")
            guard !busStops.isEmpty  else {
                keepLoading = false
                self.logger.log("\(#function) totalCount: \(totalCount))")
                continue
            }
            totalCount += busStops.count
            let toBeExcluded = try TFLBusStation.existingStationsMatchingStops(busStops, context: modelContext)
            let savedSet = Set(busStops).subtracting(toBeExcluded)
            savedSet.forEach { modelContext.insert($0) }
            try modelContext.save()
            page += stepSize
        }
    }
 
    
    
    func loadBusStopInBulk(of pageRange: Range<Int>) async -> [TFLBusStation] {
        
        await withTaskGroup(of: [TFLBusStation].self) { group in
            var stations : [TFLBusStation] = []
            pageRange.forEach { page in
                group.addTask {
                    do {
                        let stations = try await self.tflClient.busStops(with: UInt(page))
                        return stations
                    }
                    catch let error {
                        self.logger.log("\(#function)  error:\(error)")
                        return []
                    }
                }
            }
            for await newStations in group {
                stations += newStations
            }
            return stations
        }
       
    }

}
