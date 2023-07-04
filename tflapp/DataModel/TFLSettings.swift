//
//  TFLSettings.swift
//  tflapp
//
//  Created by Frank Saar on 04/07/2023.
//  Copyright © 2023 SAMedialabs. All rights reserved.
//

import Foundation
import SwiftUI


final class TFLSettings : ObservableObject {
    @Published var progressViewHidden = false
    
    func showProgress(_ show : Bool = true) {
        withAnimation {
            self.progressViewHidden = show ? false : true
        }
    }
}

