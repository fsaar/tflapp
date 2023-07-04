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
        ProgressView().phaseAnimator([false, true]) { content, value in
            content
                .scaleEffect(value ? 1.3 : 1.0)
                .opacity(value ? 0.8 : 1.0)
                .tint(.red)
        } animation: { _ in
            .easeInOut(duration: 0.5)
        }
    }
}
