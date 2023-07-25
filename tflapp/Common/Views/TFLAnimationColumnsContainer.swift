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
    static let spacing = CGFloat(10)
    static let xSpacing = CGFloat(10)
    static let symbolSize = CGSize(width:40,height:40)
    @State var offset = CGFloat(0)
    let columns : Int
    let size : CGSize
    let views : [TFLAnimationColumnView]
    let isAnimating : Bool
    init(_ size: CGSize,isAnimating: Bool) {
        self.isAnimating = isAnimating
        self.size = size
        let itemWidth = (Self.symbolSize.width + Self.xSpacing)
        self.columns  = Int((size.width / itemWidth) + 1)
        self.views = (0..<columns).map { _ in TFLAnimationColumnView(size.height,symbolSize: Self.symbolSize,spacing:Self.spacing)
        }
    }
    
    var body: some View {
        ZStack {
            ForEach(0..<columns,id:\.self) { col in
                views[col]
                    .id(col)
                    .frame(width:Self.symbolSize.width, height: 2 * size.height)
                    .position(x: CGFloat(col) * (Self.symbolSize.width + Self.xSpacing),y:-5)
                    .offset(y:offset)
            }
        }
        .task {
            animate()
        }
    }
    
    func animate() {
        guard isAnimating else {
            return
        }
        let itemHeight = Self.symbolSize.height + Self.spacing
        let itemCount = size.height / itemHeight
        let scrollDistance = itemCount * itemHeight - 2
        withAnimation(.linear(duration: 20)) {
            offset = scrollDistance
        } completion: {
            offset = 0
            animate()
        }
    }
}
