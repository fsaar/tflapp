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

@Observable
class StationList : ObservableObject {
    var list : [TFLBusStationInfo] = []
}


struct TFLNearbyBusStationListView : View {
    @State var stationInfoList : StationList
    let refreshableAction : @Sendable () async ->  Void
//    @Query(sort: \.distanceInMeters) var stations: [TFLBusStationInfo]
    var body : some View {
        ScrollView {
            LazyVStack {
                ForEach($stationInfoList.list) { station in
                    TFLBusStationView(station:station)
                }
            }
            Spacer(minLength: 80) // fix for being inside HostViewController. Change later
        }
        .refreshable(action: refreshableAction)
        .background(.tflBackground)
       
    }
}
