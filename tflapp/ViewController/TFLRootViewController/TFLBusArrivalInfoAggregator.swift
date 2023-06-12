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
                                            with distance : Double,
                                            using completionBlock:@escaping (_ arrivalInfos:[TFLBusStopArrivalsInfo],_ completed: Bool)->()) {
        let mainQueueBlock : ([TFLBusStopArrivalsInfo],Bool) -> Void = { [weak self] infos, completed in
            DispatchQueue.main.async{
                completionBlock(infos,completed)
                #if DEBUG_SCHEDULES
                guard completed else {
                    return
                }
                infos.log(with: "\(self?.counter ?? 0)")
                self?.counter += 1
                #endif
            }
        }
        let currentLocation = coord.location
        DispatchQueue.global().async{
            let context = TFLBusStopStack.sharedDataStack.privateQueueManagedObjectContext
            TFLLogger.shared.signPostStart(osLog: TFLBusArrivalInfoAggregator.loggingHandle, name: "retrieve nearby Busstops")

            TFLCDBusStop.nearbyBusStops(with: coord,with: distance,and: context) { [weak self] busStops in
                TFLLogger.shared.signPostEnd(osLog: TFLBusArrivalInfoAggregator.loggingHandle, name: "retrieve nearby Busstops")
                let threshold = 20
                if busStops.count >= threshold {
                    let initialLoad = Array(busStops[0..<threshold])
                    let remainder = Array(busStops[threshold..<busStops.count])
                    self?.arrivalsForBusStops(initialLoad, and: currentLocation) { initialInfos in
                        mainQueueBlock(initialInfos,false)
                        self?.arrivalsForBusStops(remainder, and: currentLocation) { remainderInfos in
                            let arrivalInfos = initialInfos + remainderInfos
                            if !arrivalInfos.isEmpty {
                                self?.lastUpdate = Date()
                            }
                            mainQueueBlock(arrivalInfos,true)
                        }
                    }
                }
                else {
                    self?.arrivalsForBusStops(busStops, and: currentLocation) { arrivalInfos in
                        if !arrivalInfos.isEmpty {
                            self?.lastUpdate = Date()
                        }
                        mainQueueBlock(arrivalInfos,true)
                    }
                }
            }
        }
    }
    
    func arrivalsForBusStops(_ busStops : [TFLCDBusStop],and location : CLLocation, using completionBlock:@escaping ([TFLBusStopArrivalsInfo])->()) {
        let group = DispatchGroup()
        var newStopPoints : [TFLBusStopArrivalsInfo] = []
        let context = TFLBusStopStack.sharedDataStack.privateQueueManagedObjectContext
        let queue = self.networkBackgroundQueue
        busStops.forEach { [weak self] stopPoint in
            group.enter()
            context.perform {
                self?.tflClient.arrivalsForStopPoint(with: stopPoint.identifier,with: queue) { predictions,_ in
                    context.perform {
                        let tuple = TFLBusStopArrivalsInfo(busStop: stopPoint, location: location, arrivals: predictions ?? [])
                        newStopPoints += [tuple]
                        group.leave()
                    }
                }
            }
        }
        group.notify(queue: DispatchQueue.global()) {
            completionBlock(newStopPoints)
        }
    }
    
    
}
