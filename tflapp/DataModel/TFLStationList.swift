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
import OSLog

@Observable
class TFLStationList  {
    private var radius = 400
    private let client = TFLClient()
    private let aggregator : TFLBusArrivalInfoAggregator
    var list : [TFLBusStationInfo] = []
    var cancelableSet : Set<AnyCancellable> = []
    var updating = false
    fileprivate let logger : Logger =  {
        let handle = Logger(subsystem: TFLLogger.subsystem, category: TFLLogger.category.stationList.rawValue)
        return handle
    }()
    
    init(_ aggregator : TFLBusArrivalInfoAggregator) {
        self.aggregator = aggregator
    }
    
    func refresh(location: CLLocation) async {
        guard !updating else {
            return
        }
        self.updating = true
        self.list = await updateNearbyBusStops(for: location.coordinate)
        self.updating = false
    }
    
    
    func updateList(with radius: Int,location: CLLocation) {
        
        self.radius = radius
        self.list = self.list.map { $0.stationInfoUpdateToCurrentTimeAndLocation(location) }
            .filter { !$0.arrivals.isEmpty }
            .filter {
                return $0.location.distance(from: location) < CLLocationDistance(self.radius)
            }
    }
    
    private func updateNearbyBusStops(for currentLocation:CLLocationCoordinate2D ) async -> [TFLBusStationInfo]  {
        let stations = await aggregator.loadArrivalTimesForBusStations(with: currentLocation, radius: radius)
        return stations.filter { !$0.arrivals.isEmpty }
            .sorted { $0.distance < $1.distance }
            .filter {
                return $0.location.distance(from: currentLocation.location) < CLLocationDistance(radius)
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
