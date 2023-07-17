//
//  TFLCountDownLabel.swift
//
//  Created by Frank Saar on 16/06/2023.
//

import Foundation
import SwiftUI

struct ViewSizeKey: PreferenceKey {
  static var defaultValue: CGSize = .zero
  static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
    value = nextValue()
  }
}

struct ViewGeometry: View {
  var body: some View {
    GeometryReader { geometry in
      Color.clear
        .preference(key: ViewSizeKey.self, value: geometry.size)
    }
  }
}

struct TFLCountDownLabel : View {
    enum ScrollState {
        case initial
        case updateing
        
        func offset(height: CGFloat) -> CGFloat {
            switch self {
            case .initial:
                return -height/2
            case .updateing:
                return height/2
            }
        }
    }
    @ScaledMetric(relativeTo: .title) static var defaultHeight = 16

    @Binding var value : String
    @State private var values : [String]
    @State private var scrollState : ScrollState = .initial
    @State private var size = CGSize(width: 40,height: 18)
    init(_ boundValue: Binding<String>) {
        _value = boundValue
        values = [_value.wrappedValue,_value.wrappedValue]
    }
   
    var body: some View {
        VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/) {
            text(values[0])
            text(values[1])
                .background(ViewGeometry())
                .onPreferenceChange(ViewSizeKey.self) { size in
                    self.size = size
                }
        }
        .fixedSize(horizontal: true, vertical: false)
        .lineLimit(1)
        .frame(height:size.height)
        .clipped()
        .onChange(of: value) {
            values[0] = value
            update()
        }
    }
}

//
// MARK: Helper
//
private extension TFLCountDownLabel {
    @ViewBuilder
    private func text(_ text: String) -> some View {
        Text(text)
            .frame(maxWidth: .infinity,alignment: .center)
            .offset(y: scrollState.offset(height: size.height))
    }
    
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
