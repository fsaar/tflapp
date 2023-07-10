//
//  StationList.swift
//  tflapp
//
//  Created by Frank Saar on 29/06/2023.
//  Copyright © 2023 SAMedialabs. All rights reserved.
//

import Foundation
import Observation
import CoreLocation
import Combine
import UIKit

@Observable
class TFLStationList  {
    var lastLocation : CLLocationCoordinate2D? = CLLocationCoordinate2DMake( 51.510093564781975, -0.13490563038747838)
    let radius = 400
    private let client = TFLClient()
    private let aggregator = TFLBusArrivalInfoAggregator()
    var list : [TFLBusStationInfo] = []
    var cancelableSet : Set<AnyCancellable> = []
    var updating = false
    
    func refresh() async {
        guard let currentLocation = lastLocation else {
            return
        }
        self.updating = false
        self.list = await updateNearbyBusStops(for: currentLocation)
        self.updating = true
    }
    
    
    func updateList() {
        self.list = self.list.map { $0.stationInfoUpdateToCurrentTimeAndLocation(self.lastLocation?.location) }
            .filter { !$0.arrivals.isEmpty }
            .filter {  guard let lastLocation = self.lastLocation else {
                            return true
                        }
                return $0.location.distance(from: lastLocation.location) < CLLocationDistance(self.radius)
            }
    }
    
    func updateNearbyBusStops(for currentLocation:CLLocationCoordinate2D ) async -> [TFLBusStationInfo]  {
        self.lastLocation = currentLocation
     
        let stations = await aggregator.loadArrivalTimesForBusStations(with: currentLocation, radius: radius)
        return stations.filter { !$0.arrivals.isEmpty }
            .sorted { $0.distance < $1.distance }
            .filter {
                guard let lastLocation else {
                    return true
                }
                return $0.location.distance(from: lastLocation.location) < CLLocationDistance(radius)
            }
    }
    
    ///
    /// used for debugging purposes only to simulate passing of time to verify animation and station filter
    ///
    func debug() {
        Timer.publish(every: 2, on: .main, in: .common).autoconnect().sink { _ in
            self.list = self.list.map { $0.stationInfoWithTimestampReducedBy(30) }.filter { !$0.arrivals.isEmpty }
        }.store(in:&cancelableSet)
    }
}
