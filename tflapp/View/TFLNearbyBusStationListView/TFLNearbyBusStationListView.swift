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
    @Environment(\.scenePhase) var scenePhase
   
    @State var stationInfoList = TFLStationList()
    @EnvironmentObject var settings : TFLSettings
    var body : some View {
        VStack {
//            Spacer()
//            Button("Debug") {
//                self.stationInfoList.debug()
//            }
            ScrollView {
                LazyVStack {
                    ForEach($stationInfoList.list) { station in
                        TFLBusStationView(station:station)
                            
                    }
                }
                Spacer(minLength: 140)
            }
            .refreshable {
                await stationInfoList.refresh()
            }
            .background(.tflBackground)
            .onChange(of: scenePhase) {
                if scenePhase == .active {
                    Task {
                        await refresh()
                    }
                }
            }
            
        }
        Spacer()
    }
    
    func refresh() async {
        settings.showProgress(stationInfoList.list.isEmpty)
        await stationInfoList.refresh()
        settings.showProgress(false)
    }
    
    
}
