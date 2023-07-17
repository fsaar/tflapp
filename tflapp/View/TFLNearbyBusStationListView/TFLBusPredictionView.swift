//
//  TFLBusArrivalView.swift
//

import Foundation
import SwiftUI


struct TFLBusPredictionView : View {
    let bus : String

    @State var isVisible = true
    @State var eta: String
    @Binding var prediction : TFLBusPrediction
    @ScaledMetric(relativeTo: .title) var busFontSize = 16
    @ScaledMetric(relativeTo: .body) var timeFontSize = 14
    @ScaledMetric(relativeTo: .body) var padding = 2
  
    init(_ info: Binding<TFLBusPrediction>) {
        _prediction = info
        self.bus = info.wrappedValue.lineName
        _eta = State(initialValue:info.wrappedValue.eta)
    
    }
 
    
    var body : some View {
        VStack {
            Text(prediction.lineName)
                .tflBoldFont(size:busFontSize)
                .foregroundColor(.tflSecondaryText)
                .padding(EdgeInsets(top:7,leading:20,bottom:5,trailing:20))
                .background(.tflLineBackground)
                .borderColor(shape: Capsule(), color: .tflLineBackgroundBorder)
                .contentShape(Capsule())
            TFLCountDownLabel($eta)
                .tflRegularFont(size: timeFontSize)
                .padding([.top],1)
                .padding(.horizontal,padding)
                .foregroundColor(.tflPrimaryText)
                
        }
        .padding(EdgeInsets(top:8,leading:5,bottom:5,trailing:5))
        .background(Color(.tflBusInfoBackground)
        .opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius:10))
        .contentShape(RoundedRectangle(cornerRadius:10))
        .onChange(of: prediction) {
            self.eta = prediction.eta
        }
        .scaleEffect(isVisible ? 1.0 : 0.01,anchor: .center)
        .onDisappear {
            self.isVisible = false
        }
        .onAppear {
            self.isVisible = true
        }
       
    }
}
