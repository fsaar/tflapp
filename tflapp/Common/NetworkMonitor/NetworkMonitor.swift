//
//  NetworkMonitor.swift
//  tflapp
//
//  Created by Frank Saar on 08/08/2023.
//  Copyright © 2023 SAMedialabs. All rights reserved.
//

import Foundation
import Network
import SwiftUI

@Observable
class NetworkMonitor {
    var isOnline = false
    private let monitor = NWPathMonitor()

    init() {
        monitor.pathUpdateHandler = {  path in
            self.isOnline = path.status == .satisfied
        }
        self.monitor.start(queue: .main)
        self.isOnline = self.monitor.currentPath.status  == .satisfied
      
    }
    
  
}
