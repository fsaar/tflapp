//
//  tflapp.swift
//  tflapp
//
//  Created by Frank Saar on 21/06/2023.
//  Copyright © 2023 SAMedialabs. All rights reserved.
//

import SwiftUI
import SwiftData

@main
struct TFLApp: App {
   
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(SwiftDataStack.shared.container)
    }
}
