

import SwiftUI
import Observation

struct ContentView: View {
   
    var body: some View {
        TFLNearbyBusStationListView(stationInfoList: StationList())
        Spacer()
        Text("Hello World")
    }
    
   
    
}

#Preview {
    ContentView().dynamicTypeSize(.xxxLarge)
}

