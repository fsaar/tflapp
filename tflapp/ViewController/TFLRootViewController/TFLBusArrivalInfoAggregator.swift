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
import os.signpost


class TFLBusArrivalInfoAggregator {
    fileprivate let tflClient = TFLClient()
    
    fileprivate let logger : Logger =  {
        let handle = Logger(subsystem: TFLLogger.subsystem, category: TFLLogger.category.arrivalInfoAggregator.rawValue)
        return handle
    }()
    var lastUpdate : Date?
    func loadArrivalTimesForBusStations(with stations: [TFLBusStation], location: CLLocationCoordinate2D) async -> [TFLBusStationInfo] {
        var infoList : [TFLBusStationInfo] = []
        logger.log("\(#function) retrieving arrival times for \(stations.count) stations")
        return await withTaskGroup(of: TFLBusStationInfo.self) { group in
            stations.forEach {  station in
                group.addTask(priority: .userInitiated) {
                    var stationInfo = TFLBusStationInfo(station, coordinates: location)
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
}
                 
