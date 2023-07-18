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
        case authorisation_pending
        case authorised
    }
    
    private(set) var state = State.not_authorised
    private(set) var location : CLLocation?
    private let logger : Logger =  {
        let handle = Logger(subsystem: TFLLogger.subsystem, category: TFLLogger.category.location.rawValue)
        return handle
    }()
    init() {
        let start : () -> Void = {
            Task {
                try? await self.startLocationUpdates()
            }
        }
        let authorisationStatus = locationManager.authorizationStatus
        switch authorisationStatus {
        case .notDetermined:
            self.state = .authorisation_pending
            self.locationManager.requestWhenInUseAuthorization()
            start()
        case .restricted,.denied:
            self.state = .not_authorised
        case .authorizedAlways,.authorizedWhenInUse:
            self.state = .authorised
            start()
        @unknown default:
            break
        }
    }
    
    func checkLocationUpdatesEnabled() {
        guard locationManager.authorizationStatus != .notDetermined else {
            return
        }
        let oldState = self.state
        self.state = locationUpdatesEnabled ? .authorised : .not_authorised
        switch (oldState,self.state) {
        case (_,.not_authorised):
            self.location = nil
        case (.not_authorised,.authorised):
            Task {
                try? await startLocationUpdates()
            }
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
    func startLocationUpdates() async throws {
        for try await update in CLLocationUpdate.liveUpdates() {
            if let location = update.location {
                self.location = location
                print("My current location : \(location)")
            }
            else {
                checkLocationUpdatesEnabled()
                if !locationUpdatesEnabled {
                    throw LocationError.not_authorised
                }
            }
        }
        print("failed")
    }
}
