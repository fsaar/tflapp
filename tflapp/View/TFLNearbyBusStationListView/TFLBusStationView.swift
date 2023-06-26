//
//  TFLBusStationView.swift
//

import Foundation
import SwiftUI
import Observation


struct TFLBusStationView : View {
    @Binding var station : TFLBusStationInfo
    @ScaledMetric(relativeTo:.title) var headerSize = 20
    @ScaledMetric(relativeTo:.title) var distanceSize = 18
    @ScaledMetric(relativeTo:.title) var stopCodeSize = 16
    @ScaledMetric(relativeTo:.title) var directionSize = 16
    @ScaledMetric(relativeTo:.body) var detailsPadding = 4
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    var body: some View {
        
        VStack(spacing:4) {
           
            Divider().padding([.horizontal],10).background(.tflSeparator)
            HStack(alignment: .center) {
                Text(station.name)
                    .foregroundColor(.tflPrimaryText)
                    .tflRegularFont(size: headerSize)
                    .frame(alignment: .leading)
                
                Spacer()
               
                Text(station.distance)
                    .foregroundColor(.tflPrimaryText)
                    .tflRegularFont(size: distanceSize)
                    .frame(alignment: .trailing)
                    .isHiddenInAccessibilityLevels(from: .accessibility1)
                       
               
                
            }.padding([.horizontal],10)
            HStack(spacing:0) {
                    
                Text(station.stopLetter ?? "-")
                    .tflRegularFont(size: stopCodeSize)
                    .foregroundColor(.tflStopCodeText)
                    .frame(alignment: .center)
                
                
                    .padding([.horizontal],10)
                    .padding([.vertical],4)
                    .background {
                        RoundedRectangle(cornerRadius: 7).fill(.tflStopCodeBackground)
                       
                    }
                Text(station.towards ?? "")
                    .foregroundColor(.tflPrimaryText)
                    .tflRegularFont(size: directionSize)
                    .lineLimit(3)
                    .padding([.leading],detailsPadding)
                
                Spacer()
            }.padding([.horizontal],10)
     
//            TFLBusPredictionListView(predictionList: $station.arrivals )
        }
        .background(.tflBackground)
        
    }
}


//struct TFLBusStationViewPreview : View {
//    @State var info = BusInfoList()
//    var body: some View {
//        BusStationView(station: $info.station).background(.gray)
//    }
//}
//
//#Preview {
//    TFLBusStationViewPreview()
//}

