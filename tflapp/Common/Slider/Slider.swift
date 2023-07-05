//
//  SliderHandler.swift
//  Slider
//
//  Created by Frank Saar on 03/07/2023.
//

import Foundation
import SwiftUI



private struct SliderHandle: Shape {
    func path(in rect: CGRect) -> Path {
        let radius = rect.height
        var path = Path()
        path.move(to: CGPoint(x: radius, y: 0))
        path.addLine(to:  CGPoint(x: rect.width - radius , y: 0))
        path.addArc(center: CGPoint(x: rect.width - radius, y: radius), radius: rect.height, startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
        path.addLine(to: CGPoint(x: 0 , y: rect.height))
        path.addArc(center: CGPoint(x: rect.height, y: rect.height), radius: rect.height, startAngle: .degrees(180), endAngle:  .degrees(270),clockwise: false)
        return path
    }
}


struct Slider<BackgroundView: View,ForegroundView : View> : View {
    let snapPositions: (top:Double,center: Double,bottom: Double) = (0.88,0.4,0.08)
    let backgroundView :  BackgroundView
    let foregroundView : ForegroundView
    init(@ViewBuilder backgroundViewBuilder: () -> BackgroundView,
         @ViewBuilder foregroundViewBuilder: () -> ForegroundView) {
        self.backgroundView = backgroundViewBuilder()
        self.foregroundView = foregroundViewBuilder()
    }
    @State var current = CGSize.zero
    @State var start = CGSize(width:0,height: 80)
    @State var offset = CGSize.zero
    let sliderHeight = Double(50)
    
    var body : some View {
        ZStack {
            GeometryReader { proxy in
                let height = proxy.frame(in: .global).height
                let dragGesture = DragGesture()
                    .onChanged { value in
                        withAnimation(.linear) {
                            if isValidRange(height: height, offset: value.translation) {
                                offset = value.translation
                            }
                        }
                    }.onEnded { value in
                        let snap = closestSnapPosition(height: height, offset: offset)
                        withAnimation(.bouncy) {
                            start = snap
                            offset = .zero
                        }
                    }
                
                backgroundView
                SliderHandle()
                    .fill(.tflSliderHandle)
                    .frame(height:sliderHeight)
                   
                    .offset(y: start.height + offset.height)
                    .gesture(dragGesture)
                   
                foregroundView.offset(y: start.height + offset.height+sliderHeight)
            }
            
        }.ignoresSafeArea()
    }
    
    func isValidRange(height: Double,offset: CGSize) -> Bool {
        let final = start.height + offset.height
        let coords = (top: snapPositions.top * height, center:snapPositions.center * height,bottom: snapPositions.bottom * height)
        let isValid =  coords.bottom...coords.top ~= final
        return isValid
    }
    
    func closestSnapPosition(height: Double,offset: CGSize) -> CGSize {
        let final = start.height + offset.height
        let coords = (top: snapPositions.top * height, center:snapPositions.center * height,bottom: snapPositions.bottom * height)
        let snapPositions = [coords.top,coords.center,coords.bottom]
        let values = snapPositions.enumerated().map { ($0.0,abs($0.1 - final)) }.sorted { $0.1 < $1.1 }.first ?? (0,0)
        let snapPosition = snapPositions[values.0]
        return CGSizeMake(offset.width, snapPosition)

    }
}
