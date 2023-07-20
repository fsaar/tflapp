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
    
    enum State : Equatable {
        case not_updating
        case updating(CLLocation)
        static func ==(lhs: Self,rhs: Self) -> Bool {
            switch (lhs,rhs) {
            case (.not_updating,.not_updating),(.updating,.updating):
                return true
            default:
                return false
            }
        }
        var locationAvailable : Bool {
            switch self {
            case .updating:
               return true
            case .not_updating:
               return false
            }
        }
    }
    
    var isLocationNotDetermined : Bool {
        locationManager.authorizationStatus == .notDetermined
    }
    
    var isAuthorised : Bool {
        [.authorizedAlways,.authorizedWhenInUse].contains(locationManager.authorizationStatus)
    }
    
    private(set) var state = State.not_updating
   
    private let logger : Logger =  {
        let handle = Logger(subsystem: TFLLogger.subsystem, category: TFLLogger.category.location.rawValue)
        return handle
    }()
    
    func checkLocationUpdatesEnabled() async {
        if case .notDetermined =  locationManager.authorizationStatus  {
            logger.log("\(#function) requesting authorisation &  restarting location update")
            self.locationManager.requestWhenInUseAuthorization()
            await start()
            return
        }
        let isEnabled = locationUpdatesEnabled
        
        switch (self.state,isEnabled) {
        case (.updating,false):
            self.state = .not_updating
            logger.log("\(#function) location update unauthorised")
        case (.not_updating,true):
            logger.log("\(#function) restarting location update")
            await start()
        default:
            break
        }
    }
    
    func stopLocationUpdates() {
        self.state = .not_updating
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
        self.state = .not_updating
        logger.log("\(#function) location update unauthorised")
    }
    
    func startLocationUpdates() async throws {
        for try await update in CLLocationUpdate.liveUpdates() {
            if let location = update.location {
                self.state = .updating(location)
                logger.log("\(#function) updated location")
            }
            else {
                if !locationUpdatesEnabled {
                    logger.log("\(#function) location update disabled")
                    throw LocationError.not_authorised
                }
            }
        }
    }
}