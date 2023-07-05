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

    func refresh() async {
        guard let currentLocation = lastLocation else {
            return
        }
        self.list = await updateNearbyBusStops(for: currentLocation)
    }
    
    init() {
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification).sink {_ in
            let tempList = self.list.map { $0.stationInfoUpdateToCurrentTimeAndLocation(self.lastLocation?.location) }
                .filter { !$0.arrivals.isEmpty }
            if let lastLocation = self.lastLocation {
                self.list = tempList.filter { $0.location.distance(from: lastLocation.location) < CLLocationDistance(self.radius) }
            }
            else {
                self.list = tempList
            }
            
        }.store(in: &cancelableSet)
    }
    
    
    func updateNearbyBusStops(for currentLocation:CLLocationCoordinate2D ) async -> [TFLBusStationInfo]  {
        self.lastLocation = currentLocation
     
        let stations = await aggregator.loadArrivalTimesForBusStations(with: currentLocation, radius: radius)
        let filteredStations = stations.filter { !$0.arrivals.isEmpty }
                                        .sorted { $0.distance < $1.distance }
        guard let lastLocation else {
            return filteredStations
        }
        
        return filteredStations.filter { $0.location.distance(from: lastLocation.location) < CLLocationDistance(radius) }
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
