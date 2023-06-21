//
//  TFLBusArrivalInfo.swift
//  tflapp
//
//  Created by Frank Saar on 20/06/2023.
//  Copyright © 2023 SAMedialabs. All rights reserved.
//

import Foundation

struct BusArrivalInfo : Identifiable,Equatable {
    static func ==(lhs: Self,rhs: Self) -> Bool {
        return lhs.id == rhs.id
    }
    
    let line : String
    let eta : String
    let accessibilityTimeToStation : String
    let identifier : String
    let busStopIdentifier : String
    let vehicleID : String
    let timeToStation : Int
    let towards : String
    var id : String {
        return identifier
    }
    
    init(_ model: TFLBusStopArrivalsViewModel.LinePredictionViewModel) {
        self.line = model.line
        self.eta = model.eta
        self.accessibilityTimeToStation = model.accessibilityTimeToStation
        self.identifier = model.identifier
        self.busStopIdentifier = model.busStopIdentifier
        self.vehicleID = model.vehicleID
        self.timeToStation = model.timeToStation
        self.towards = model.towards
    }
}
