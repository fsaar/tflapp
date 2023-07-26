//
//  GenerateDatabaseButton.swift
//  tflapp
//
//  Created by Frank Saar on 26/07/2023.
//  Copyright © 2023 SAMedialabs. All rights reserved.
//

import Foundation
import SwiftData
import SwiftUI

struct GenerateDatabaseButton : View {
    @State private var busStopDBGenerator : TFLBusStopDBGenerator?
    @Environment(\.modelContext) private var context
    var body : some View {
        Button("Create Database") {
            Task {
                if case .none = busStopDBGenerator {
                    busStopDBGenerator = TFLBusStopDBGenerator(context.container)
                }
                try? await self.busStopDBGenerator?.loadBusStops()
            }
        }
    }
}
