

import SwiftUI
import SwiftData

// 1. Retrieve Nearby Busstops
// 2. Retrive Arrival Times for nearby Busstops

struct ContentView: View {
   
    private let busStopDBGenerator = TFLBusStopDBGenerator()
    var body: some View {
        VStack {
            Button("Create Database") {
                Task {
                    
                    try? await self.busStopDBGenerator.loadBusStops()
                }
              
//                { [weak self] in
//                    self?.busStopDBGenerator.loadLineStations()
//                }
            }
            Spacer()
            TFLNearbyBusStationListView()
            Spacer()
        }
     
    }
   
   
    
}

#Preview {
    ContentView().dynamicTypeSize(.xxxLarge)
}
