import SwiftUI


struct TFLNoStationListView : View {
    @Environment(\EnvironmentValues.stationList) private var stationList
   
    var body : some View {
        NoContentAvailableView(title: "TFLNoStationsView.title",description: "TFLNoStationsView.description") {
            
            RetryButton {
                Task {
                    await stationList.wrappedValue.refresh()
                }
            }
            
        }
        
        .padding(10)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .stroke(.tflNoStationsListViewBorder,lineWidth:2)
        }
        .padding(10)
    }
        
}
