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


private struct StationListKey: EnvironmentKey {
    static let defaultValue : Binding<TFLStationList> = .constant(TFLStationList())
}


extension EnvironmentValues {
    var settings: TFLSettings {
        set { self[SettingsKey.self] = newValue }
        get { self[SettingsKey.self] }
    }
    
    var stationList: Binding<TFLStationList> {
        set { self[StationListKey.self] = newValue }
        get { self[StationListKey.self] }
    }
}

@main
struct TFLApp: App {
    @State var stationList = TFLStationList()
    @Environment(\.scenePhase) var scenePhase
    var settings = TFLSettings()
    var body: some Scene {
        WindowGroup {
            ZStack {
                Slider(backgroundViewBuilder: {
                    Map()
                })  {
                    ContentView()
                }
                .isHidden(stationList.list.isEmpty)
                .environment(\.settings,settings)
                .environment(\.stationList,$stationList)
                TFLProgressView().isHidden(settings.progressViewHidden)
            }.onChange(of: scenePhase) {
                if scenePhase == .active {
                    Task {
                        await refresh()
                    }
                }
            }
           
           
        }
        .modelContainer(SwiftDataStack.shared.container)
        
    }
    
    func refresh() async {
        settings.showProgress(stationList.list.isEmpty)
        await stationList.refresh()
        settings.showProgress(false)
    }
}
