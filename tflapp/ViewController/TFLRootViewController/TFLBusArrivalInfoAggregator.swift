//
//  TFLBusArrivalInfoAggregator.swift
//  tflapp
//
//  Created by Frank Saar on 04/08/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//
import MapKit
import Foundation
import UIKit
import os.signpost



class TFLBusArrivalInfoAggregator {
    fileprivate let tflClient = TFLClient()
    fileprivate static let loggingHandle  = OSLog(subsystem: TFLLogger.subsystem, category: TFLLogger.category.arrivalInfoAggregator.rawValue)
    fileprivate let networkBackgroundQueue = OperationQueue()
    private var counter : Int = 0
    var lastUpdate : Date?
    func loadArrivalTimesForStoreStopPoints(with coord: CLLocationCoordinate2D,
                                            with distance : Double) async -> [TFLBusStopArrivalsInfo] {
        let currentLocation = coord.location
        
        let context = TFLBusStopStack.sharedDataStack.privateQueueManagedObjectContext
        TFLLogger.shared.signPostStart(osLog: TFLBusArrivalInfoAggregator.loggingHandle, name: "retrieve nearby Busstops")
        let busStops = await withCheckedContinuation { continuation in
            TFLCDBusStop.nearbyBusStops(with: coord,with: distance,and: context) { busStops in
                continuation.resume(returning: busStops)
            }
        }
        TFLLogger.shared.signPostEnd(osLog: TFLBusArrivalInfoAggregator.loggingHandle, name: "retrieve nearby Busstops")
        
        let arrivalInfos = await arrivalsForBusStops(busStops, and: currentLocation)
        lastUpdate = !arrivalInfos.isEmpty ? Date() : lastUpdate
        return arrivalInfos
    }
    
    func arrivalsForBusStops(_ busStops : [TFLCDBusStop],and location : CLLocation) async -> [TFLBusStopArrivalsInfo] {
       
        var newStopPoints : [TFLBusStopArrivalsInfo] = []
        
        await withTaskGroup(of: TFLBusStopArrivalsInfo.self) { group in
            busStops.forEach { stopPoint in
                group.addTask(priority: .medium) {
                    let predictions = await self.tflClient.arrivalsForStopPoint(with: stopPoint.identifier)
                    let context = TFLBusStopStack.sharedDataStack.privateQueueManagedObjectContext
                    let info = await context.perform {
                        TFLBusStopArrivalsInfo(busStop: stopPoint, location: location, arrivals: predictions)
                    }
                    return info
                }
            }
            for await info in group  {
                newStopPoints += [info]
            }
        }
        return newStopPoints
        
    }
    
    
}
