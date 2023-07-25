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
    let isAnimating : Bool
    var body : some View {
        GeometryReader { proxy in
            TFLAnimationColumnsContainer(proxy.size,isAnimating: isAnimating)
        }.ignoresSafeArea()
    }
}
