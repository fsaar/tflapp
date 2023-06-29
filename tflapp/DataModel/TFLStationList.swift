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

    private let client = TFLClient()
    private let aggregator = TFLBusArrivalInfoAggregator()
    var list : [TFLBusStationInfo] = []
    var cancelableSet : Set<AnyCancellable> = []
    private let currentLocation = CLLocationCoordinate2DMake( 51.510093564781975, -0.13490563038747838)
    func refresh() async {
        self.list = await updateNearbyBusStops(for: currentLocation)
    }
    
    init() {
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification).sink {_ in 
            self.list = self.list.map { $0.stationInfoUpdateToCurrentTime() }.filter { !$0.arrivals.isEmpty }
        }.store(in: &cancelableSet)
    }
    
    func updateNearbyBusStops(for currentLocation:CLLocationCoordinate2D ) async -> [TFLBusStationInfo]  {
        let stations = await aggregator.loadArrivalTimesForBusStations(with: currentLocation, radius: Int(400))
        return stations.filter { !$0.arrivals.isEmpty }.sorted { $0.distance < $1.distance }
    }
    
    
    
    func debug() {
        Timer.publish(every: 2, on: .main, in: .common).autoconnect().sink { _ in
            self.list = self.list.map { $0.stationInfoWithTimestampReducedBy(30) }.filter { !$0.arrivals.isEmpty }
        }.store(in:&cancelableSet)
    }
}
