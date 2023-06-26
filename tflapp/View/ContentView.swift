

import SwiftUI
import SwiftData

// 1. Retrieve Nearby Busstops
// 2. Retrive Arrival Times for nearby Busstops

struct ContentView: View {
   
 
    var body: some View {
        TFLNearbyBusStationListView()
        Spacer()
    }
   
   
    
}

#Preview {
    ContentView().dynamicTypeSize(.xxxLarge)
}
