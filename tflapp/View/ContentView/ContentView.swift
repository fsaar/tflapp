

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

// requestStations: has Location && is Active
// NoContentView: has Location && has no content
// NoLocationView: has no location && location status !== not determined && isActive
// Hide Progress : has content || no update in progress


struct ContentView: View {
    
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("Distance") private var distance = 400
    @Environment(TFLStationList.self) private var stationList
    @Environment(LocationManager.self) private var locationManager
    @State var isUpdating = false
    @State var stationSelection = TFLBusstationSelection()
   
    @State var foreground = false
    var requestStations : Bool {
        self.locationManager.state.locationAvailable && foreground
    }
    var showNoLocation : Bool {
        let isLocationNotDetermined = self.locationManager.isLocationNotDetermined
        let locationAvailable =  self.locationManager.state.locationAvailable
        return !isLocationNotDetermined && !locationAvailable && foreground
    }
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
            .isHidden(showContentUnavailable || showNoLocation)
            if showNoLocation {
                TFLNoLocationView()
            }
            else if showContentUnavailable {
                TFLNoStationListView()
            }
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
       
        .onChange(of: requestStations) {
            guard requestStations, case .authorised(let location) = locationManager.state  else {
                return
            }
            stationList.updateList(with: self.distance, location: location)
            Task {
                await stationList.refresh(location: location)
            }
        }
        .onChange(of: stationList.updating) {
            withAnimation {
                self.isUpdating = self.stationList.updating
            }
        }
        .onChange(of: scenePhase) {
            self.foreground = scenePhase == .active
        }
    }
}

#Preview {
    ContentView().dynamicTypeSize(.xxxLarge)
}
