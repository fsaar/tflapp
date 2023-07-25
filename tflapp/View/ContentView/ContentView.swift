

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
// NoContentView: has Location && has no content && foreground
// NoLocationView: has no location && location status !== not determined && isActive
// AnimationView: as no location && location status == not determined && isActive
// Hide Progress : has content || no update in progress


struct ContentView: View {
    enum ViewState {
        case noLocation
        case contentUnavailable
        case runAnimation
        case busSchedules
    }
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("Distance") private var distance = 400
    @Environment(TFLStationList.self) private var stationList
    @Environment(LocationManager.self) private var locationManager
    @State var isUpdating = false
    @State var stationSelection = TFLBusstationSelection()
    @State var viewState : ViewState = .runAnimation
    @State var foreground = false
    var requestStations : Bool {
        self.locationManager.state.locationAvailable && foreground
    }
    var locationNotAvailable : Bool {
        self.locationManager.state.locationAvailable
    }
    var noContent : Bool {
        self.stationList.list.isEmpty
    }
    var locationNotDetermined : Bool {
        self.locationManager.isLocationNotDetermined
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
            .isHidden(viewState != .busSchedules)
    
            TFLNoLocationView()
                .isHidden(viewState != .noLocation)
            TFLNoStationListView()
                .isHidden(viewState != .contentUnavailable)
            TFLAnimationView(isAnimating: false).opacity(0.15)
                .isHidden(viewState != .runAnimation)

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
            guard requestStations, case .updating(let location) = locationManager.state  else {
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
            updateState()
        }
        .onChange(of: scenePhase) {
            self.foreground = scenePhase == .active
            updateState()
        }
        .onChange(of: locationNotAvailable) {
           updateState()
        }
        .onChange(of: noContent) {
            updateState()
        }
        .onChange(of: locationNotDetermined) {
            updateState()
        }
    }
    
    @MainActor
    func updateState() {
        let oldState = viewState
        let newState : ViewState
        switch (isUpdating,locationNotAvailable,locationNotDetermined,noContent) {
        case (_,_,true,true):
            newState = .runAnimation
        case (true,_,_,true):
            newState = .runAnimation
        case (true,_,_,false):
            newState = .busSchedules
        case (false,true,_,true):
            newState = .noLocation
        case (false,_,_,true):
            newState = .contentUnavailable
        case (false, _, _, false):
            newState = .busSchedules
        }
        guard oldState != newState else {
            return
        }
        withAnimation(.linear(duration: 0.5)) {
            viewState = newState
        }
    }
}

#Preview {
    ContentView().dynamicTypeSize(.xxxLarge)
}
