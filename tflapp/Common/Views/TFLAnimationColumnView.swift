//
//  TFLAnimationColumnView.swift
//  tflapp
//
//  Created by Frank Saar on 25/07/2023.
//  Copyright © 2023 SAMedialabs. All rights reserved.
//

import Foundation
import SwiftUI


struct TFLAnimationColumnView : View {
    
    let symbolSize : CGSize
    let count : Int
    let spacing : CGFloat
    let symbols : [String]
    
    static let symbols =  ["bus.doubledecker.fill","bus.fill"]
    init(_ height: CGFloat, symbolSize: CGSize,spacing: CGFloat) {
        self.spacing = spacing
        let itemHeight = (symbolSize.height + spacing)
        let pageCount = Int(height / itemHeight)
        self.count = 2 * pageCount
        self.symbolSize = symbolSize
        self.symbols = (0..<pageCount).compactMap { _ in Self.symbols.randomElement() ?? "" }
    }
    
    var body: some View {
        VStack(spacing: spacing) {
            let range: Range<Int> = (0..<self.count)
            ForEach(range,id:\.self) { index in
                let pageIndex = index % (self.count / 2)
                Image(systemName:self.symbols[pageIndex])
                    .resizable()
                    .renderingMode(.original)
                    .foregroundColor(.tflAnimationViewSymbol)
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width:symbolSize.width)
                    .padding([.leading],symbolSize.width)
            }
        }
        .padding(0)
    }
}
