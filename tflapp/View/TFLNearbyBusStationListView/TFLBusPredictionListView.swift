//
//  TFLBusArrivalListView.swift
//

import Foundation
import SwiftUI


struct TFLBusPredictionListView : View {
    @State var isVisible = true
    @Binding var predictionList : [TFLBusPrediction]
    @State var firstId : TFLBusPrediction.ID?
    var body : some View {
        ScrollView(.horizontal,showsIndicators: false) {
            LazyVStack {
                HStack {
                    ForEach($predictionList) { prediction in
                        TFLBusPredictionView(prediction)
                            .animation(.bouncy) {
                                $0.scaleEffect(isVisible ? 1.0 : 0.01,anchor: .center)
                            }
                    }
                } .animation(.linear(duration: 0.4),value:predictionList)
            }
        }
        .scrollPosition(id: $firstId)
        .safeAreaPadding([.leading],10)
        .onDisappear {
            self.isVisible = false
        }
                                
        .onAppear {
            self.isVisible = true
        }
    }
}
