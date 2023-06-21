//
//  TFLBusArrivalView.swift
//

import Foundation
import SwiftUI


struct TFLBusArrivalView : View {
    let bus : String

    @State var eta: String
    @Binding var busArrivalInfo : BusArrivalInfo
    @ScaledMetric(relativeTo: .title) var busFontSize = 16
    @ScaledMetric(relativeTo: .body) var timeFontSize = 14
    @ScaledMetric(relativeTo: .body) var padding = 2

    init(_ info: Binding<BusArrivalInfo>) {
        _busArrivalInfo = info
        self.bus = info.wrappedValue.line
        _eta = State(initialValue:info.wrappedValue.eta)
    
    }
 
    
    var body : some View {
        VStack {
            Text("\(bus)")
                .tflBoldFont(size:busFontSize)
                .foregroundColor(.tflSecondaryText)
                .padding(EdgeInsets(top:7,leading:20,bottom:5,trailing:20))
                .background(.tflLineBackground)
                .borderColor(shape: Capsule(), color: .tflLineBackgroundBorder)
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
        .onChange(of: busArrivalInfo) {
            self.eta = _busArrivalInfo.wrappedValue.eta
        }
           
    }
}
