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

private struct SettingsKey: EnvironmentKey {
  static let defaultValue = TFLSettings()
}

extension EnvironmentValues {
  var settings: TFLSettings {
    get { self[SettingsKey.self] }
    set { self[SettingsKey.self] = newValue }
  }
}

@main
struct TFLApp: App {
    var settings = TFLSettings()
    var body: some Scene {
        WindowGroup {
            ZStack {
                Slider(backgroundViewBuilder: {
                    Map()
                })  {
                    ContentView()
                }.environment(\.settings,settings)
                TFLProgressView().isHidden(settings.progressViewHidden)
            }
           
           
        }
        .modelContainer(SwiftDataStack.shared.container)
        
    }
}
