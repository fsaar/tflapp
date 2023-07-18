

import Foundation
import SwiftUI
import Observation
import MapKit
import SwiftData

@Observable
final class TFLBusstationSelection {
    var station : TFLBusStationInfo?
}

struct GenerateDatabaseButton : View {
    @State private var busStopDBGenerator : TFLBusStopDBGenerator?
    @Environment private var container : ModelContainer
   
    var body : some View {
        Button("Create Database") {
            Task {
                if case .none = busStopDBGenerator {
                    busStopDBGenerator = TFLBusStopDBGenerator(self.container)
                }
                try? await self.busStopDBGenerator?.loadBusStops()
            }
        }
    }
}


struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("Distance") private var distance = 400
    @Environment(TFLStationList.self) private var stationList
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
                stationList.updateList(with: self.distance)
                Task {
                    await stationList.refresh()
                }
            }
        }.onChange(of: stationList.updating) {
            withAnimation {
                self.isUpdating = self.stationList.updating

            }
        }
    }
}

#Preview {
    ContentView().dynamicTypeSize(.xxxLarge)
}
