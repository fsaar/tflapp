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
    fileprivate let lightImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    @Environment(TFLBusstationSelection.self) private var stationSelection
    @Environment(TFLStationList.self) private var stationList
    @Environment(LocationManager.self) private var locationManager
    
    @State var scrollPostion : String?
    var body : some View {
        
        VStack {
            ScrollView(showsIndicators: false) {
                LazyVStack {
                    ForEach(stationList.list) { station in
                        TFLBusStationView(station:Binding.constant(station))
                            .onTapGesture {
                                withAnimation {
                                    stationSelection.station =  station
                                }
                            }
                            .scrollTransition(axis: .vertical,transition:transitionEffect)
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
                guard case .updating(let location) = locationManager.state else {
                    return
                }
                lightImpactFeedbackGenerator.prepare()
                lightImpactFeedbackGenerator.impactOccurred()
                Task {
                    await stationList.refresh(location: location)
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
    @Sendable
   
    private func transitionEffect(_ content: EmptyVisualEffect,phase: ScrollTransitionPhase) -> some VisualEffect {
        content
    }
    
}
