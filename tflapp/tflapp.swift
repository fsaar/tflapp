//
//  tflapp.swift
//  tflapp
//
//  Created by Frank Saar on 21/06/2023.
//  Copyright © 2023 SAMedialabs. All rights reserved.
//

import SwiftUI
import SwiftData


@main
struct TFLApp: App {
    @Environment(\.scenePhase) private var scenePhase
    let swiftDataStack : SwiftDataStack
    let stationList : TFLStationList
    let locationManager = LocationManager()
    init() {
        guard let stack = try? SwiftDataStack() else {
            fatalError("Unable to initialise SwiftData")
        }
        swiftDataStack = stack
        let aggregator = TFLBusArrivalInfoAggregator(stack.container)
        stationList = TFLStationList(aggregator)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(stationList)
                .onChange(of:scenePhase) {
                    if scenePhase == .active {
                        Task {
                          await  locationManager.checkLocationUpdatesEnabled()
                        }
                    }
                }
        }
        .modelContainer(swiftDataStack.container)
    }
    
}
