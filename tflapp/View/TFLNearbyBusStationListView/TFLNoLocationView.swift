import SwiftUI


struct TFLNoLocationView : View {
   
    @Environment(LocationManager.self) private var locationManager
    @Environment(\.openURL) var openURL
    var body : some View {
        NoContentAvailableView(title: "TFLNoGPSEnabledView.headerTitle",description: "TFLNoStationsView.description") {
           
            Link("TFLNoGPSEnabledView.settingsButtonTitle", destination: URL(string: UIApplication.openSettingsURLString)!)
                .padding(10)
                .background(.tflButton)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 10)).padding([.top],20)
        }

        .padding(10)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .stroke(.tflNoLocationViewBorder,lineWidth:2)
                
        }
        .padding(10)
       
    }
        
}
