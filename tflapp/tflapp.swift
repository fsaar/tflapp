//
//  tflapp.swift
//  tflapp
//
//  Created by Frank Saar on 21/06/2023.
//  Copyright © 2023 SAMedialabs. All rights reserved.
//

import SwiftUI
import SwiftData
import MapKit

@main
struct TFLApp: App {
    @ObservedObject var settings = TFLSettings()
    var body: some Scene {
        WindowGroup {
            ZStack {
                Slider(backgroundViewBuilder: {
                    Map()
                })  {
                    ContentView()
                }.environmentObject(settings)
                TFLProgressView().isHidden(settings.progressViewHidden)
            }
           
           
        }
        .modelContainer(SwiftDataStack.shared.container)
        
    }
}
