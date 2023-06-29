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




struct TFLNearbyBusStationListView : View {
    @State var stationInfoList = TFLStationList()
  
    var body : some View {
        VStack {
            Spacer()
            Button("Debug") {
                self.stationInfoList.debug()
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
