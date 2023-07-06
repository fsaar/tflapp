

import Foundation
import SwiftUI
import Observation
import MapKit

struct SettingsKey: EnvironmentKey {
    static let defaultValue = TFLSettings()
}


struct StationListKey: EnvironmentKey {
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

struct GenerateDatabaseButton : View {
    private let busStopDBGenerator = TFLBusStopDBGenerator()
    
    var body : some View {
        Button("Create Database") {
            Task {
                try? await self.busStopDBGenerator.loadBusStops()
            }
        }
    }
}

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\EnvironmentValues.settings) private var settings : TFLSettings
    @Environment(\EnvironmentValues.stationList) private var stationList
    var body: some View {
        ZStack {
            Slider(backgroundViewBuilder: {
                Map()
            })  {
                VStack {
//                    GenerateDatabaseButton()
//                    Spacer()
                    TFLNearbyBusStationListView()
                    Spacer()
                }.background(.white)
            }
            .isHidden(stationList.list.isEmpty)
            
            let showContentUnavailable = stationList.list.isEmpty && settings.progressViewHidden
            
            NoContentAvailableView(title: "TFLNoStationsView.title",description: "TFLNoStationsView.description") {
                RetryButton {
                    Task {
                        await refresh()
                    }
                    
                }
                
            }
            .isHidden(!showContentUnavailable)
            TFLProgressView().isHidden(settings.progressViewHidden)
            
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                Task {
                    await refresh()
                }
            }
        }
    }
    
    
    func refresh() async {
        settings.showProgress(stationList.list.isEmpty)
        await stationList.wrappedValue.refresh()
        settings.showProgress(false)
    }
    
}

#Preview {
    ContentView().dynamicTypeSize(.xxxLarge)
}
