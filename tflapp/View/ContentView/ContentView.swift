

import Foundation
import SwiftUI
import Observation
import MapKit
import SwiftData

@Observable
final class TFLBusstationSelection {
    var station : TFLBusStationInfo?
}



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
   
    let monitor = NetworkMonitor()
    var showOffline : Bool {
        !self.monitor.isOnline && viewState != .runAnimation
    }
    
    var requestStations : Bool {
        self.locationManager.state.locationAvailable && foreground
    }
    var locationNotAvailable : Bool {
        !self.locationManager.state.locationAvailable
    }
    var notAuthorised : Bool {
        !self.locationManager.isAuthorised
    }
    var noContent : Bool {
        self.stationList.list.isEmpty
    }
    var locationNotDetermined : Bool {
        self.locationManager.isLocationNotDetermined
    }
   
    var hideProgress : Bool {
        !stationList.list.isEmpty || !isUpdating
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
            TFLAnimationView().opacity(0.15)
                .isHidden(viewState != .runAnimation)
            
            TFLProgressView().isHidden(hideProgress)
            
        }
        .overlay {
                VStack {
                    Spacer()
                    OfflineView()
                        .padding(10)
                }
                .offset(y: showOffline ? 0 : UIScreen.main.bounds.height)
                .animation(.spring(duration:0.5,bounce:0.2), value: showOffline)
                
            
        }
        
   
#if DEBUG_TOOLS
        .safeAreaInset(edge: .bottom) {
            HStack(spacing:40) {
                Spacer()
                Button("Debug") {
                    self.stationList.debug()
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
        let location = (notAuthorised,locationNotAvailable,locationNotDetermined)
        switch (isUpdating,location,noContent) {
        case (_,(_,_,true),true):
            newState = .runAnimation
        case (true,_,true):
            newState = .runAnimation
        case (true,_,false):
            newState = .busSchedules
        case (_,(true,_,false),_):
            newState = .noLocation
        case (false,(false,_,_),true):
            newState = .contentUnavailable
        case (false, _, false):
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
