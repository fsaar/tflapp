//
//  TFLCountDownLabel.swift
//
//  Created by Frank Saar on 16/06/2023.
//

import Foundation
import SwiftUI


struct TFLCountDownLabel : View {
    enum ScrollState {
        case initial
        case updateing
        
        func offset(height: CGFloat) -> CGFloat {
            switch self {
            case .initial:
                return -height
            case .updateing:
                return 0
            }
        }
    }
  
    private var normalizedText : String {
        let maxText = values[0].count > values[1].count ? values[0] : values[1]
        return Array(repeating:"x",count:maxText.count+1).joined(separator: "")
    }
    @Binding var value : String
    @State var width : CGFloat = 0
    @State private var values : [String]
    @State private var scrollState : ScrollState = .initial
    init(_ boundValue: Binding<String>) {
        _value = boundValue
        values = [_value.wrappedValue,_value.wrappedValue]
    }
    var body: some View {
            Text(normalizedText)
                .frame(minWidth: width, alignment: .center)
                .lineLimit(1)
                .opacity(0.01)
                .overlay {
                    GeometryReader { proxy in
                        VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) {
                            ForEach(0..<2,id:\.self) { index in
                                Text(values[index])
                                    .frame(width: proxy.size.width,alignment: .center)
                                    .offset(y: scrollState.offset(height: proxy.size.height))
                            }
                        } .onChange(of: value) {
                            if width == 0 {
                                width = proxy.size.width
                            }
                            values[0] = _value.wrappedValue
                            update()
                            
                                    }
                    }
                }.clipped()
    }
}

//
// MARK: Helper
//
private extension TFLCountDownLabel {
    func update() {
        withAnimation(.spring(duration:0.6,bounce:0.6)) {
            self.scrollState = .updateing
        } completion: {
            self.values[1] = values[0]
            withAnimation(.linear(duration:0)) {
                self.scrollState = .initial
            }
        }
    }
}
