

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
    @AppStorage("Distance") private var distance = 400
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
            SliderView(backgroundViewBuilder: {
                TFLMapBusStationView()
            })  {
                TFLNearbyBusStationListView()
            }
            .environment(stationSelection)
            .isHidden(stationList.list.isEmpty)
            TFLNoStationListView()
                .isHidden(!showContentUnavailable)
            TFLProgressView().isHidden(hideProgress)
            
        }
#if DEBUG_TOOLS
        .safeAreaInset(edge: .bottom) {
            HStack(spacing:40) {
                Spacer()
                Button("Debug") {
                    self.stationList.wrappedValue.debug()
                }
                .padding(10)
                .overlay {
                    RoundedRectangle(cornerRadius: 10).stroke(.white,lineWidth:2)
                }
                
                
                GenerateDatabaseButton()
                    .padding(10)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10).stroke(.white,lineWidth:2)
                    }
                Spacer()
            }.padding(10)
                .background(.thinMaterial)
                .isHidden(stationList.list.isEmpty)
        }
#endif
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                stationList.wrappedValue.updateList(with: self.distance)
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
