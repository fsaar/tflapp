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
   
    @Environment(\.stationList) var stationList : Binding<TFLStationList>
    var body : some View {
        VStack {
//            Spacer()
//            Button("Debug") {
//                self.stationInfoList.debug()
//            }
            ScrollView(showsIndicators: false) {
                LazyVStack {
                    ForEach(stationList.list) { station in
                        TFLBusStationView(station:station)
                            .scrollTransition(axis: .vertical) { content, phase in
                                content
                                    .scaleEffect(
                                        x: phase.isIdentity ? 1.0 : 0.90,
                                        y: phase.isIdentity ? 1.0 : 0.90)
                                }
                        
                    }
                }
                .scrollTargetLayout()
            }
            .safeAreaPadding([.bottom],140)
            .scrollTargetBehavior(.viewAligned)
            .refreshable {
                await stationList.wrappedValue.refresh()
            }
            .background(.tflBackground)
            
        }
        Spacer()
    }

    
}
