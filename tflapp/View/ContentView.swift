

import SwiftUI
import CoreLocation
import SwiftData

// 1. Retrieve Nearby Busstops
// 2. Retrive Arrival Times for nearby Busstops

struct ContentView: View {
    @Settings(key: .distance,defaultValue: 400) fileprivate var settingDistance : Double
    @AppStorage("Distance") fileprivate var distance = Double(400)
   
    @Environment(\.modelContext) var modelContext
    let client = TFLClient()
    let aggregator = TFLBusArrivalInfoAggregator()
    @State var stationList =  StationList()
    var currentLocation = CLLocationCoordinate2DMake( 51.510093564781975, -0.13490563038747838)
    var body: some View {
        TFLNearbyBusStationListView(stationInfoList: stationList) { 
            await refresh()
        }.task {
            
            await refresh()
        }
        Spacer()
    }
   
    func refresh() async {
        stationList.list = await updateNearbyBusStops(for: currentLocation)
    }
    
    func updateNearbyBusStops(for currentLocation:CLLocationCoordinate2D ) async -> [TFLBusStationInfo]  {
        let stops = await self.client.nearbyBusStops(with: currentLocation,radius: Int(settingDistance))
//        stops.forEach { stop in
//            modelContext.insert(stop)
//        }
        let stations = await aggregator.loadArrivalTimesForBusStations(with: stops, location: currentLocation)
//        stations.forEach { station in
//            modelContext.insert(station)
//        }
        return stations.sorted { $0.distance < $1.distance }
    }
    
}

#Preview {
    ContentView().dynamicTypeSize(.xxxLarge)
}
