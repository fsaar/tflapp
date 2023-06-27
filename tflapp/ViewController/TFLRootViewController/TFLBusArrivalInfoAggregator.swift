//
//  TFLBusArrivalInfoAggregator.swift
//  tflapp
//
//  Created by Frank Saar on 04/08/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//
import MapKit
import Foundation
import CoreLocation
import UIKit
import SwiftData
import OSLog


class TFLBusArrivalInfoAggregator {
    fileprivate let tflClient = TFLClient()
    
    fileprivate let logger : Logger =  {
        let handle = Logger(subsystem: TFLLogger.subsystem, category: TFLLogger.category.arrivalInfoAggregator.rawValue)
        return handle
    }()
    var lastUpdate : Date?
    
   
    func loadArrivalTimesForBusStations(with location: CLLocationCoordinate2D,radius: Int) async -> [TFLBusStationInfo] {
        var infoList : [TFLBusStationInfo] = []
        let modelContext = ModelContext(SwiftDataStack.shared.container)
        let stations = await TFLBusStation.nearbyBusStops(with: location, and: modelContext)
        updateDatabase(for: location,radius: radius)
        logger.log("\(#function) retrieving arrival times for \(stations.count) stations")
        return await withTaskGroup(of: TFLBusStationInfo.self) { group in
            stations.forEach {  station in
                group.addTask(priority: .userInitiated) {
                    var stationInfo = TFLBusStationInfo(station, userCoordinates: location)
                    let arrivals  = (try? await self.tflClient.arrivalsForStopPoint(with: stationInfo.identifier)) ?? []
                    stationInfo.arrivals = arrivals.sorted { $0.etaInSeconds < $1.etaInSeconds }
                    return stationInfo
                }
            }
            for await info in group {
                infoList += [info]
            }
            let filteredList = infoList.filter { !$0.arrivals.isEmpty }
            logger.log("\(#function) \(filteredList.count) arrival times retrieved")
            lastUpdate = Date()
            return filteredList
        }
    }
    
    func updateDatabase(for currentLocation: CLLocationCoordinate2D,radius: Int)  {
        Task.detached {
            let modelContext = ModelContext(SwiftDataStack.shared.container)
            let busStops = await self.tflClient.nearbyBusStops(with: currentLocation,radius: radius)
            let toBeExcluded = try TFLBusStation.existingStationsMatchingStops(busStops, context: modelContext)
            let savedSet = Set(busStops).subtracting(toBeExcluded)
            savedSet.forEach { modelContext.insert($0) }
        }
    }
}
                 
