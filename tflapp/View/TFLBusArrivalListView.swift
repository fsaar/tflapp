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


struct TFLBusArrivalListView : View {
    @Binding var busInfoList : [BusArrivalInfo]
   
    func isLast(_ info: BusArrivalInfo) -> Bool {
        guard !busInfoList.isEmpty else {
            return true
        }
        return busInfoList.last == info
    }
    var body : some View {
        
        ScrollView(.horizontal,showsIndicators: false) {
            LazyVStack {
                LazyHStack {
                    ForEach($busInfoList) { bus in
                        TFLBusArrivalView(bus).transition(.asymmetric(insertion: .scaleOut, removal:  .scaleDown))
                            
                    }
//                    TFLBusArrivalView($dummy).opacity(0.01) // prevents HStack from vertically shrinking
                }
               
            }
           
        }
        .safeAreaPadding([.leading],10)
      
    }
                                
                                
}
