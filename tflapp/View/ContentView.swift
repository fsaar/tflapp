

import Foundation
import SwiftUI
import Observation
import MapKit

@Observable
final class TFLBusstationSelection {
    var station : TFLBusStationInfo?
   
   
}

struct StationListKey: EnvironmentKey {
    static let defaultValue : Binding<TFLStationList> = .constant(TFLStationList())
}

struct BusstationSelectionKey: EnvironmentKey {
    static let defaultValue : Binding<TFLBusstationSelection> = .constant(TFLBusstationSelection())
}


extension EnvironmentValues {
   
    var stationList: Binding<TFLStationList> {
        set { self[StationListKey.self] = newValue }
        get { self[StationListKey.self] }
    }
    
    var stationSelection: Binding<TFLBusstationSelection> {
        set { self[BusstationSelectionKey.self] = newValue }
        get { self[BusstationSelectionKey.self] }
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
    @Environment(\EnvironmentValues.stationList) private var stationList
    @State var isUpdating = true
    @State var stationSelection = TFLBusstationSelection()
    var showContentUnavailable : Bool {
        self.stationList.list.isEmpty && !self.isUpdating
    }
    var hideProgress : Bool {
        !stationList.list.isEmpty || !self.isUpdating
    }
    
    var body: some View {
        ZStack {
            Slider(backgroundViewBuilder: {
                TFLMapBusStationView()
            })  {
                ZStack {
                    VStack {
                        Text("yo")
                        Spacer()
                    }
                    VStack {
    //                    GenerateDatabaseButton()
    //                    Spacer()
                        TFLNearbyBusStationListView()
                        Spacer()
                    }.background(.white)
                }
                
            }
            .environment(\.stationSelection,$stationSelection)
            .isHidden(stationList.list.isEmpty)
            TFLNoStationListView()
                .isHidden(!showContentUnavailable)
            TFLProgressView().isHidden(hideProgress)
            
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                stationList.wrappedValue.updateList()
                Task {
                    await stationList.wrappedValue.refresh()
                }
            }
        }.onChange(of: stationList.updating.wrappedValue) {
            withAnimation {
                self.isUpdating = self.stationList.updating.wrappedValue

            }
        }
    }
}

#Preview {
    ContentView().dynamicTypeSize(.xxxLarge)
}
