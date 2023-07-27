//
//  TFLAnimationColumnsContainer.swift
//  tflapp
//
//  Created by Frank Saar on 25/07/2023.
//  Copyright © 2023 SAMedialabs. All rights reserved.
//

import Foundation
import SwiftUI

struct TFLAnimationColumnsContainer : View {
    private let spacing: (x:CGFloat,y:CGFloat)
    private let symbolSize: CGSize
    @State var offset = CGFloat(0)
    let columns : Int
    let size : CGSize
    let views : [TFLAnimationColumnView]
    init(_ size: CGSize,spacing: (x:CGFloat,y:CGFloat),symbolSize: CGSize) {
        self.size = size
        let itemWidth = (symbolSize.width + spacing.x)
        self.columns  = Int((size.width / itemWidth) + 1)
        self.spacing = spacing
        self.symbolSize = symbolSize
        self.views = (0..<columns).map { _ in TFLAnimationColumnView(size.height,symbolSize: symbolSize,spacing:spacing.y)
        }
    }
    
    var body: some View {
        ZStack {
            ForEach(0..<columns,id:\.self) { col in
                views[col]
                    .id(col)
                    .frame(width:symbolSize.width, height: 2 * size.height)
                    .position(x: CGFloat(col) * (symbolSize.width + spacing.x),y:-5)
            }
        }
        
    }
    
   
}
