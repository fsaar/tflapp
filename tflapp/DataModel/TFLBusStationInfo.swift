//
//  TFLBusStationInfo.swift
//  tflapp
//
//  Created by Frank Saar on 20/06/2023.
//  Copyright © 2023 SAMedialabs. All rights reserved.
//

import Foundation

public class TFLBusStationInfo : Identifiable {
    var stationName : String
    var stopLetter : String
    var stationDetails : String
    var busStopDistance : Double
    var distance : String
    var arrivals : [BusArrivalInfo]
    
    public var id : String {
        return stationName
    }
    
    init(_ model :TFLBusStopArrivalsViewModel) {
        self.stopLetter = model.stopLetter
        self.stationName = model.stationName
        self.stationDetails = model.stationDetails
        self.busStopDistance = model.busStopDistance
        self.distance = model.distance
        self.arrivals = model.arrivalTimes.map { BusArrivalInfo($0) }
    }
}
