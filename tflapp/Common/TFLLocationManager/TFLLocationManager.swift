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
        case authorisation_pending(completionBlock : TFLLocationManagerCompletionBlock?)
        case autorised(completionBlock : TFLLocationManagerCompletionBlock?)
    }
    
    fileprivate static let locationLoggingHandle : OSLog =  {
        let handle = OSLog(subsystem: TFLLogger.subsystem, category: TFLLogger.category.location.rawValue)
        return handle
    }()
    var lastKnownCoordinate = kCLLocationCoordinate2DInvalid
    static let sharedManager = TFLLocationManager()
    var completionBlock : TFLLocationManagerCompletionBlock?
    var enabled : Bool? {
        var enabled : Bool? = nil
        let authorisationStatus = CLLocationManager.authorizationStatus()
        switch authorisationStatus {
        case .notDetermined:
            break
        case .restricted,.denied:
            enabled = false
        default:
            enabled = true
        }
        return enabled

    }
    let locationManager =  CLLocationManager()
  
   
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        if case .none = self.enabled {
            self.locationManager.requestWhenInUseAuthorization()
        }
        else if enabled == true {
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
        guard self.enabled == true else {
            if self.enabled == false {
                completionBlock?(kCLLocationCoordinate2DInvalid)
            }
            else {
                self.completionBlock = completionBlock
            }
            return
        }
       
        TFLLogger.shared.signPostStart(osLog: TFLLocationManager.locationLoggingHandle, name: "updateLocation")
        self.completionBlock = { coord in
            TFLLogger.shared.signPostEnd(osLog: TFLLocationManager.locationLoggingHandle, name: "updateLocation")
            completionBlock?(coord)
        }
        self.locationManager.requestLocation()
    }
}

/// MARK: CLLocationManagerDelegate

extension TFLLocationManager : CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let coordinate = locations.first?.coordinate ?? kCLLocationCoordinate2DInvalid
        lastKnownCoordinate = coordinate
        DispatchQueue.main.async {
            self.completionBlock?(coordinate)
            self.completionBlock = nil
        }
    }
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.completionBlock?(kCLLocationCoordinate2DInvalid)
            self.completionBlock = nil
        }
    }
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            self.locationManager.startUpdatingLocation()
            if let block = completionBlock {
                self.completionBlock = nil
                self.requestLocation(using: block)
            }

        case .notDetermined:
            break
        default:
            self.completionBlock?(kCLLocationCoordinate2DInvalid)
            self.completionBlock = nil
        }
    }
}
