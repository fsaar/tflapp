//
//  TFLProgressView.swift
//  tflapp
//
//  Created by Frank Saar on 04/07/2023.
//  Copyright © 2023 SAMedialabs. All rights reserved.
//

import SwiftUI

struct TFLProgressView : View {
   
  
    var body: some View {
        HStack(spacing:20) {
            ProgressView().phaseAnimator([false, true]) { content, value in
                content
                    .scaleEffect(value ? 1.3 : 1.0)
                    .opacity(value ? 0.8 : 1.0)
                    .tint(.tflProgressViewBorder)
            } animation: { _ in
                .easeInOut(duration: 0.5)
            }
            Text("TFLProgressView.title").font(.headline).foregroundColor(.tflPrimaryText)
        }
        .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
        .padding(20)
        .overlay {
            Capsule().stroke(.tflProgressViewBorder,lineWidth:2)
        }
       
    }
}
