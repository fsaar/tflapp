//
//  TFLBusArrivalListView.swift
//

import Foundation
import SwiftUI


struct TFLBusPredictionListView : View {
    @Binding var predictionList : [TFLBusPrediction]
    @State var firstId : TFLBusPrediction.ID?
    var body : some View {
        
        ScrollView(.horizontal,showsIndicators: false) {
            LazyVStack {
                LazyHStack {
                    ForEach($predictionList) { prediction in
                        TFLBusPredictionView(prediction)
                            .transition(.opacity.animation(.linear(duration: 0.20)))
                            .animation(.linear(duration: 0.4),value:predictionList)
                    }
                }
            }
           
        }
        .scrollPosition(id: $firstId)
        .safeAreaPadding([.leading],10)
    }
}
