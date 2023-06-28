//
//  TFLBusArrivalListView.swift
//

import Foundation
import SwiftUI


extension AnyTransition {
    static var scaleDown : AnyTransition {
        .scale(scale: 0.01,anchor: .init(x: 0, y: 0.5)).combined(with: .opacity).animation(.linear(duration: 0.25))
    }
    
    static var scaleOut : AnyTransition {
        .scale.combined(with: .opacity).animation(.linear(duration:0.25))
    }
}


struct TFLBusPredictionListView : View {
    @Binding var predictionList : [TFLBusPrediction]
   
    var body : some View {
        
        ScrollView(.horizontal,showsIndicators: false) {
            LazyVStack {
                LazyHStack {
                    ForEach($predictionList) { prediction in
                        TFLBusPredictionView(prediction)
                    }
                }
            }
           
        }
        .safeAreaPadding([.leading],10)
    }
}
