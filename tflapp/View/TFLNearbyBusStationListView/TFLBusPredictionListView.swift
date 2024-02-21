//
//  TFLBusArrivalListView.swift
//

import Foundation
import SwiftUI


struct TFLBusPredictionListView : View {
    @State var isVisible = true
    @Binding var predictionList : [TFLBusPrediction]
    @State var firstId : TFLBusPrediction.ID?
    let tflClient = TFLClient()
    var body : some View {
        ScrollView(.horizontal,showsIndicators: false) {
            HStack {
                ForEach($predictionList) { prediction in
                    TFLBusPredictionView(prediction)
                        .scaleEffect(isVisible ? 1.0 : 0.01,anchor: .center)
                        .transaction(value:self.isVisible) {
                            $0.animation = self.isVisible ? nil : $0.animation
                        }
                        .onTapGesture {
                            let line = prediction.wrappedValue.lineName
                            print("\(prediction.wrappedValue.lineName)")
                            Task {
                                _ = try? await tflClient.lineStationInfo(for: line)
                            }
                          
                        }
                }
            } .animation(.linear(duration: 0.4),value:predictionList)
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
