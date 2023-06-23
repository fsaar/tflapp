//
//  TFLBusStationInfo.swift
//  tflapp
//
//  Created by Frank Saar on 20/06/2023.
//  Copyright © 2023 SAMedialabs. All rights reserved.
//

import Foundation
import SwiftData
import CoreLocation


@Model
public class TFLBusStationInfo : Identifiable {
    fileprivate static let distanceFormatter : LengthFormatter = {
        let formatter = LengthFormatter()
        formatter.unitStyle = .short
        formatter.numberFormatter.roundingMode = .halfUp
        formatter.numberFormatter.maximumFractionDigits = 0
        return formatter
    }()
    @Attribute(.unique) var identifier : String
    var name : String
    var stopLetter : String?
    var towards : String?
    var distanceInMeters : Double
    var distance : String
// FIXME: uncomment
//    @Relationship(.cascade) var arrivals : [TFLBusPrediction] = []
    @Transient var arrivals : [TFLBusPrediction] = []
    public var id : String {
        return identifier
    }
    
    init(_ station: TFLBusStation, coordinates: CLLocationCoordinate2D) {
        self.identifier = station.identifier
        self.name = station.name
        self.stopLetter = station.stopLetter
        self.towards = station.towards
        self.distanceInMeters = coordinates.location.distance(from: station.location)
        self.distance = Self.distanceFormatter.string(fromValue: distanceInMeters, unit: .meter)

    }
}
