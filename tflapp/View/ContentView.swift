

import Foundation
import SwiftUI
import Observation
import MapKit


struct StationListKey: EnvironmentKey {
    static let defaultValue : Binding<TFLStationList> = .constant(TFLStationList())
}

extension EnvironmentValues {
   
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
    @Environment(\EnvironmentValues.stationList) private var stationList
    @State var isUpdating = true
    
    var showContentUnavailable : Bool {
        self.stationList.list.isEmpty && !self.isUpdating
    }
    var hideProgress : Bool {
        !stationList.list.isEmpty || !self.isUpdating
    }
    
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
