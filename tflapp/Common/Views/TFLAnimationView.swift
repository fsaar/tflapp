//
//  TFLAnimationView.swift
//  tflapp
//
//  Created by Frank Saar on 20/07/2023.
//  Copyright © 2023 SAMedialabs. All rights reserved.
//
import Foundation
import SwiftUI




struct TFLAnimationView : View {
    private let symbolSize = CGSize(width:40,height:40)
    private let spacing = (x:CGFloat(10),y:CGFloat(10))
   
    var body : some View {
        GeometryReader { proxy in
            let vw = TFLAnimationColumnsContainer(proxy.size,spacing: spacing,symbolSize: symbolSize)
            
            let itemHeight = symbolSize.height + spacing.y
            let itemCount = proxy.size.height / itemHeight
            let scrollDistance = itemCount * itemHeight - 2
            TimelineView(.animation) { context in

                let value = (context.date.timeIntervalSince1970 * 10).truncatingRemainder(dividingBy: scrollDistance)
                vw
                    .animation(.linear) {
                        $0.offset(y: value)
                    }
            }
        }.ignoresSafeArea()
    }
}
