//
//  TFLNearbyBusStationListView.swift
//  tflapp
//
//  Created by Frank Saar on 13/06/2023.
//  Copyright © 2023 SAMedialabs. All rights reserved.
//

import Foundation
import SwiftUI
import Observation
import SwiftData
import CoreLocation
import Combine

@Observable
class StationList  {
//    @Settings(key: .distance,defaultValue: 400) fileprivate var settingDistance : Double
//    @AppStorage("Distance") fileprivate var distance = Double(400)
//    @Environment(\.modelContext) var modelContext

    private let client = TFLClient()
    private let aggregator = TFLBusArrivalInfoAggregator()
    var list : [TFLBusStationInfo] = []
    private let currentLocation = CLLocationCoordinate2DMake( 51.510093564781975, -0.13490563038747838)
    func refresh() async {
        self.list = await updateNearbyBusStops(for: currentLocation)
    }
    
    func updateNearbyBusStops(for currentLocation:CLLocationCoordinate2D ) async -> [TFLBusStationInfo]  {
     
        let stations = await aggregator.loadArrivalTimesForBusStations(with: currentLocation, radius: Int(400))
        return stations.filter { !$0.arrivals.isEmpty }.sorted { $0.distance < $1.distance }
    }
    var set : Set<AnyCancellable> = []
    func start() {
        Timer.publish(every: 2, on: .main, in: .common).autoconnect().sink { _ in
            self.list = self.list.map { $0.stationInfoWithTimestampReducedBy(30) }
        }.store(in:&set)
    }
}


struct TFLNearbyBusStationListView : View {
    @State var stationInfoList = StationList()
  
    var body : some View {
        VStack {
            Spacer()
            Button("Debug") {
                self.stationInfoList.start()
            }
            ScrollView {
                LazyVStack {
                    ForEach($stationInfoList.list) { station in
                        TFLBusStationView(station:station)
                    }
                }
            }
            .refreshable {
                await stationInfoList.refresh()
            }
            .background(.tflBackground)
            .task {
                await stationInfoList.refresh()
            }
        }
        Spacer()
        

       
    }
}
