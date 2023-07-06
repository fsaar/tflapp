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
    @State var stationList = TFLStationList()
    var settings = TFLSettings()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.settings,settings)
                .environment(\.stationList,$stationList)
        }
        .modelContainer(SwiftDataStack.shared.container)
    }
    
}
