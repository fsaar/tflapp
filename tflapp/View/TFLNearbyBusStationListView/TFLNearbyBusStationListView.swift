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
    @Environment(TFLBusstationSelection.self) var stationSelection
    @Environment(\.stationList) var stationList : Binding<TFLStationList>
    @State var scrollPostion : String?
    var body : some View {
        
        VStack {
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
                            .onTapGesture {
                                withAnimation {
                                    stationSelection.station =  station.wrappedValue
                                }
                            }
                        
                    }
                }
                .background(.tflBackground)
                .scrollTargetLayout()
            }
            .scrollPosition(id: $scrollPostion)
            .background {
                VStack {
                    Spacer().frame(height:60)
                    Text("TFLRootViewController.ackTitle")
                        .font(.title)
                        .foregroundColor(.tflLicenseInfoHeaderFont)
                        .frame(alignment:.center)
                    
                    Text("TFLRootViewController.ackSubTitle")
                        .font(.headline)
                        .foregroundColor(.tflLicenseInfoBodyFont)
                        .padding([.top],10)
                    Spacer()
                }
                .dynamicTypeSize(...DynamicTypeSize.large)   
                .padding(10)
                
            }
            .background(.tflBackground)
            .safeAreaPadding([.bottom],140)
            .scrollTargetBehavior(.viewAligned)
            .refreshable {
                Task {
                    await stationList.wrappedValue.refresh()
                }
            }
            .onChange(of:stationSelection.station) {
                guard let station = stationSelection.station,scrollPostion != station.identifier else  {
                    return
                }
                withAnimation {
                    scrollPostion = station.identifier
                }
            }
            
        }
        Spacer()
    }

    
}
