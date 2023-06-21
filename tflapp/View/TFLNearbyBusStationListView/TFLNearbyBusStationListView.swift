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

@Observable
class StationList : ObservableObject {
    var list : [TFLBusStationInfo] = []
}


struct TFLNearbyBusStationListView : View {
    @State var stationInfoList : StationList
    
    var body : some View {
        ScrollView {
            LazyVStack {
                Spacer()
                ForEach(0..<stationInfoList.list.count,id:\.self) { index in
                    TFLBusStationView(station:$stationInfoList.list[index])
                }
//                ForEach($stationInfoList.list) { station in
//                    TFLBusStationView(station:station)
//                }
                Spacer()
            }
            Spacer(minLength: 80) // fix for being inside HostViewController. Change later
        }
        .background(.tflBackground)
       
    }
}
