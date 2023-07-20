import SwiftUI


struct TFLNoStationListView : View {
    @Environment(TFLStationList.self) private var stationList
    @Environment(LocationManager.self) private var locationManager
    @State var locationAvailable = false
    var body : some View {
        NoContentAvailableView(title: "TFLNoStationsView.title",description: "TFLNoStationsView.description") {
            
            RetryButton {
                guard case .updating(let location) = locationManager.state else {
                    return
                }
                Task {
                    await stationList.refresh(location: location)
                }
            }.disabled(!locationAvailable)
            
        }
        
        .padding(10)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .stroke(.tflNoStationsListViewBorder,lineWidth:2)
        }
        .padding(10)
        .onChange(of:locationManager.state) {
            self.locationAvailable = locationManager.state.locationAvailable
           
        }
    }
        
}
