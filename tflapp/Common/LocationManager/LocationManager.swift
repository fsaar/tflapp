//
//  LocationManager.swift
//  tflapp
//
//  Created by Frank Saar on 18/07/2023.
//  Copyright © 2023 SAMedialabs. All rights reserved.
//

import Foundation
import CoreLocation
import Observation
import OSLog

@Observable
final class LocationManager {
    enum LocationError : Error {
        case not_authorised
    }
    
    private let locationManager : CLLocationManager = {
        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.pausesLocationUpdatesAutomatically = false
        return manager
    }()
    
    enum State {
        case not_authorised
        case authorised(CLLocation)
    }
    
    private(set) var state = State.not_authorised
   
    private let logger : Logger =  {
        let handle = Logger(subsystem: TFLLogger.subsystem, category: TFLLogger.category.location.rawValue)
        return handle
    }()
    init() {}
    
    func checkLocationUpdatesEnabled() async {
        if case .notDetermined =  locationManager.authorizationStatus  {
            self.locationManager.requestWhenInUseAuthorization()
            await start()
            return
        }
        let isEnabled = locationUpdatesEnabled
        
        switch (self.state,isEnabled) {
        case (_,false):
            self.state = .not_authorised
        case (.not_authorised,true):
            await start()
        default:
            break
        }
    }
    
    var locationUpdatesEnabled : Bool {
        let authorisationStatus = locationManager.authorizationStatus
        switch authorisationStatus {
        case .authorizedAlways,.authorizedWhenInUse:
            return true
        default:
            return false
        }
    }
}

private extension LocationManager  {
    func start() async {
        try? await self.startLocationUpdates()
        self.state = .not_authorised
    }
    
    func startLocationUpdates() async throws {
        for try await update in CLLocationUpdate.liveUpdates() {
            if let location = update.location {
                self.state = .authorised(location)
                print("My current location : \(location)")
            }
            else {
                if !locationUpdatesEnabled {
                    throw LocationError.not_authorised
                }
            }
        }
        print("failed")
    }
}
