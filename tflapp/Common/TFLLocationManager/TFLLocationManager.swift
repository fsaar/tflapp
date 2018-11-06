import CoreLocation
import Foundation
import UIKit
import os.signpost

typealias TFLLocationManagerCompletionBlock  = (CLLocationCoordinate2D)->(Void)


protocol TFLLocationManagerDelegate : class {
    func locationManager(_ locationManager : TFLLocationManager, didChangeEnabledStatus enabled : Bool)
}

class TFLLocationManager : NSObject {
    weak var delegate : TFLLocationManagerDelegate?
    private enum State {
        case not_authorised
        case authorisation_pending(completionBlocks : [TFLLocationManagerCompletionBlock])
        case authorised
        case authorised_requestPending(completionBlocks : [TFLLocationManagerCompletionBlock])

        func stateWithCompletionBlock(_ completionBlock : TFLLocationManagerCompletionBlock?) -> State {
            switch self {
            case .not_authorised,.authorised:
                return self
            case let .authorisation_pending(completionBlocks):
                if let completionBlock = completionBlock {
                    return State.authorisation_pending(completionBlocks: completionBlocks + [completionBlock])
                }
                return self
            case let .authorised_requestPending(completionBlocks):
                if let completionBlock = completionBlock {
                    return State.authorised_requestPending(completionBlocks: completionBlocks + [completionBlock])
                }
                return self
            }
        }
        
        var stateWithoutCompletionBlocks : State {
            switch self {
            case .not_authorised,.authorised:
                return self
            case .authorisation_pending:
                return State.authorisation_pending(completionBlocks: [])
            case .authorised_requestPending:
                return State.authorised_requestPending(completionBlocks: [])
            }
        }
        
        var completionBlocks : [TFLLocationManagerCompletionBlock] {
            switch self {
            case .not_authorised,.authorised:
                return []
            case let .authorisation_pending(completionBlocks),let .authorised_requestPending(completionBlocks):
                return completionBlocks
            }
        }
    }
    
    fileprivate static let locationLoggingHandle : OSLog =  {
        let handle = OSLog(subsystem: TFLLogger.subsystem, category: TFLLogger.category.location.rawValue)
        return handle
    }()
    private var state = State.not_authorised
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
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        let authorisationStatus = CLLocationManager.authorizationStatus()
        switch authorisationStatus {
        case .notDetermined:
            self.state = .authorisation_pending(completionBlocks: [])
            self.locationManager.requestWhenInUseAuthorization()
        case .restricted,.denied:
            self.state = .not_authorised
        case .authorizedAlways,.authorizedWhenInUse:
            // need to wait for didChangeAuthorization callback even when authorised
            self.state = .authorisation_pending(completionBlocks: [])
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
            self.state = State.authorised_requestPending(completionBlocks:[{ coord  in
                TFLLogger.shared.signPostEnd(osLog: TFLLocationManager.locationLoggingHandle, name: "updateLocation")
                completionBlock?(coord)
            }])
            self.locationManager.requestLocation()
        case .authorised_requestPending:
            TFLLogger.shared.signPostStart(osLog: TFLLocationManager.locationLoggingHandle, name: "updateLocation")
            self.state = state.stateWithCompletionBlock { coord  in
                TFLLogger.shared.signPostEnd(osLog: TFLLocationManager.locationLoggingHandle, name: "updateLocation")
                completionBlock?(coord)
            }
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
            let completionBlocks = self.state.completionBlocks
            self.state = State.authorised
            completionBlocks.forEach { $0(coordinate) }
        }
    }
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            objc_sync_enter(self)
            defer {
                objc_sync_exit(self)
            }
            let completionBlocks = self.state.completionBlocks
            if case .authorised_requestPending = self.state {
                self.state = State.authorised
            }
            else {
                self.state = self.state.stateWithoutCompletionBlocks
            }
            completionBlocks.forEach { $0(kCLLocationCoordinate2DInvalid) }
        }
    }
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }

        switch status {
        case .authorizedWhenInUse,.authorizedAlways:
            if case .authorised = state {
                precondition(false,"Invalid state. State must not be authorised")
            }
            locationManager.startUpdatingLocation()
            let completionBlocks = self.state.completionBlocks
            state = State.authorised
            completionBlocks.forEach { requestLocation(using:$0) }
            self.delegate?.locationManager(self, didChangeEnabledStatus: true)
        case .notDetermined:
            break
        case .restricted,.denied:
            self.state.completionBlocks.forEach { $0(kCLLocationCoordinate2DInvalid) }
            self.state = .not_authorised
            self.delegate?.locationManager(self, didChangeEnabledStatus: false)
        }
    }
}
