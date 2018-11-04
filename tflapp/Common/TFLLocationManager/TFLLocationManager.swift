import CoreLocation
import Foundation
import UIKit
import os.signpost

typealias TFLLocationManagerCompletionBlock  = (CLLocationCoordinate2D)->(Void)

extension CLLocationCoordinate2D {
    public static func ==(lhs : CLLocationCoordinate2D,rhs : CLLocationCoordinate2D) -> Bool {
        return (lhs.latitude == rhs.latitude) && (lhs.longitude == rhs.longitude)
    }
    
    var isValid : Bool {
        let isNonNull = (self.latitude != 0) && (self.longitude != 0)
        let isValid = CLLocationCoordinate2DIsValid(self)
        return isNonNull && isValid
    }
}



class TFLLocationManager : NSObject {
    enum State {
        case not_authorised
        case authorisation_pending(completionBlocks : [TFLLocationManagerCompletionBlock])
        case authorised(completionBlocks : [TFLLocationManagerCompletionBlock])
        
        func stateWithCompletionBlock(_ completionBlock : TFLLocationManagerCompletionBlock?) -> State {
            switch self {
            case .not_authorised:
                return self
            case let .authorisation_pending(completionBlocks):
                if let completionBlock = completionBlock {
                    return State.authorisation_pending(completionBlocks: completionBlocks + [completionBlock])
                }
                return self
            case let .authorised(completionBlocks):
                if let completionBlock = completionBlock {
                    return State.authorisation_pending(completionBlocks: completionBlocks + [completionBlock])
                }
                return self
            }
        }
        
        var stateWithoutCompletionBlocks : State {
            switch self {
            case .not_authorised:
                return self
            case .authorisation_pending(_):
                return State.authorisation_pending(completionBlocks: [])
            case .authorised(_):
                return State.authorised(completionBlocks: [])
            }
        }
        
        var completionBlocks : [TFLLocationManagerCompletionBlock] {
            switch self {
            case .not_authorised:
                return []
            case let .authorisation_pending(completionBlocks),let .authorised(completionBlocks):
                return completionBlocks
            }
        }
    }
    
    fileprivate static let locationLoggingHandle : OSLog =  {
        let handle = OSLog(subsystem: TFLLogger.subsystem, category: TFLLogger.category.location.rawValue)
        return handle
    }()
    var state = State.not_authorised
    static let sharedManager = TFLLocationManager()
    var enabled : Bool {
        guard case .authorised = state else {
            return false
        }
        return true

    }
    let locationManager =  CLLocationManager()
  
   
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
        let authorisationStatus = CLLocationManager.authorizationStatus()
        switch authorisationStatus {
        case .notDetermined:
            self.state = .authorisation_pending(completionBlocks: [])
            self.locationManager.requestWhenInUseAuthorization()
        case .restricted,.denied:
            break
        default:
            self.state = .authorised(completionBlocks: [])
            self.locationManager.startUpdatingLocation()
        }
    
    }

    func updateLocation(completionBlock: @escaping  TFLLocationManagerCompletionBlock)  {
        requestLocation(using: completionBlock)
    }
}

/// MARK: Private

fileprivate extension TFLLocationManager {
    func requestLocation(using completionBlock:  TFLLocationManagerCompletionBlock?)  {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }
        switch self.state {
        case .not_authorised:
            completionBlock?(kCLLocationCoordinate2DInvalid)
        case .authorisation_pending:
            state = state.stateWithCompletionBlock(completionBlock)
        case .authorised:
            TFLLogger.shared.signPostStart(osLog: TFLLocationManager.locationLoggingHandle, name: "updateLocation")
            state = state.stateWithCompletionBlock { coord in
                TFLLogger.shared.signPostEnd(osLog: TFLLocationManager.locationLoggingHandle, name: "updateLocation")
                completionBlock?(coord)
            }
            self.locationManager.requestLocation()
        }
    }
}

/// MARK: CLLocationManagerDelegate

extension TFLLocationManager : CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let coordinate = locations.first?.coordinate ?? kCLLocationCoordinate2DInvalid
        DispatchQueue.main.async {
            objc_sync_enter(self)
            defer {
                objc_sync_exit(self)
            }
            self.state.completionBlocks.forEach { $0(coordinate) }
            self.state = self.state.stateWithoutCompletionBlocks
        }
    }
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            objc_sync_enter(self)
            defer {
                objc_sync_exit(self)
            }
            self.state.completionBlocks.forEach { $0(kCLLocationCoordinate2DInvalid) }
            self.state = self.state.stateWithoutCompletionBlocks
        }
    }
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }

        switch status {
        case .authorizedWhenInUse:
            guard case .authorisation_pending = state else {
                precondition(false,"Invalid state. State needs to be authorisation pending")
            }
            self.locationManager.startUpdatingLocation()
            let completionBlocks = self.state.completionBlocks
            self.state = State.authorised(completionBlocks: [])
            completionBlocks.forEach { requestLocation(using:$0) }
        case .notDetermined:
            break
        default:
            self.state.completionBlocks.forEach { $0(kCLLocationCoordinate2DInvalid) }
            self.state = self.state.stateWithoutCompletionBlocks
        }
    }
}
