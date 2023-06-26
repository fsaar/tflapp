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
   
    let container : ModelContainer

    init() {
        do {
            let container =  try ModelContainer(for: [TFLBusStation.self], ModelConfiguration(schema: Schema([TFLBusStation.self]),inMemory:true))
            self.container = container
        }
        catch let error {
            fatalError("Unable to initialise ModelContainer:\(error)")
        }
        
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
}
