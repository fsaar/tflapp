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
import Observation


public struct TFLBusStationInfo : Identifiable,Equatable {
    fileprivate static let distanceFormatter : LengthFormatter = {
        let formatter = LengthFormatter()
        formatter.unitStyle = .short
        formatter.numberFormatter.roundingMode = .halfUp
        formatter.numberFormatter.maximumFractionDigits = 0
        return formatter
    }()
    static public func ==(lhs: Self,rhs: Self) -> Bool {
        return lhs.name == rhs.name &&  lhs.stopLetter == rhs.stopLetter && lhs.towards == rhs.towards && lhs.distanceInMeters == rhs.distanceInMeters
    }
    let identifier : String
    let name : String
    let stopLetter : String?
    let towards : String?
    let distanceInMeters : Double
    let distance : String
    var lat: Double
    var long: Double
    
    var location : CLLocation {
        return CLLocation(latitude: lat, longitude: long)
    }
    var arrivals : [TFLBusPrediction] = []
    
    public var id : String {
        return identifier
    }
    
    init(_ station: TFLBusStation, userCoordinates: CLLocationCoordinate2D) {
        self.identifier = station.identifier
        self.name = station.name
        self.stopLetter = station.stopLetter
        self.towards = station.towards
        self.distanceInMeters = userCoordinates.location.distance(from: station.location)
        self.distance = Self.distanceFormatter.string(fromValue: distanceInMeters, unit: .meter)
        self.lat = station.lat
        self.long = station.long
    }
    
    ///
    /// used for debugging purposes only to simulate passing of time to verify animation and station filter
    ///
    init(_ station: TFLBusStationInfo, seconds: Int) {
        self.identifier = station.identifier
        self.name = station.name
        self.stopLetter = station.stopLetter
        self.towards = station.towards
        self.distanceInMeters = station.distanceInMeters
        self.distance = station.distance
        self.lat = station.lat
        self.long = station.long
        self.arrivals = station.arrivals.map { $0.predictionoWithTimestampReducedBy(seconds) }.filter { $0.etaInSeconds > 0 }
    }
    
    ///
    /// used for copying stationinfo adjusted to current time
    ///
    init(_ station: TFLBusStationInfo,_ location: CLLocation?) {
        self.identifier = station.identifier
        self.name = station.name
        self.stopLetter = station.stopLetter
        self.towards = station.towards
        self.lat = station.lat
        self.long = station.long
        if let location = location {
            self.distanceInMeters = location.distance(from: CLLocation(latitude: station.lat, longitude: station.long))
        }
        else {
            self.distanceInMeters = station.distanceInMeters
        }
        self.distance = Self.distanceFormatter.string(fromValue: distanceInMeters, unit: .meter)
        self.arrivals = station.arrivals.map { $0.predictionsUpdatedToCurrentTime() }.filter { $0.etaInSeconds > 0 }
    }
    
   
    ///
    /// used for debugging purposes only to simulate passing of time to verify animation and station filter
    ///
    func stationInfoWithTimestampReducedBy(_ seconds : Int) -> TFLBusStationInfo {
        let new = TFLBusStationInfo(self,seconds: seconds)
        return new
       
    }
    
    ///
    /// used for copying stationinfo adjusted to current time
    ///
    func stationInfoUpdateToCurrentTimeAndLocation(_ location: CLLocation?) -> TFLBusStationInfo {
        let new = TFLBusStationInfo(self,location)
        return new
       
    }
}
