import CoreLocation
import Foundation
import UIKit

typealias TFLLocationManagerCompletionBlock  = (CLLocationCoordinate2D)->(Void)

extension CLLocationCoordinate2D {
    public static func ==(lhs : CLLocationCoordinate2D,rhs : CLLocationCoordinate2D) -> Bool {
        return (lhs.latitude == rhs.latitude) && (lhs.longitude == rhs.longitude)
    }
}

class TFLLocationManager : NSObject {
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
    var foregroundNotificationHandler : TFLNotificationObserver?
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        if case .none = self.enabled {
            self.locationManager.requestWhenInUseAuthorization()
        }
        self.foregroundNotificationHandler = TFLNotificationObserver(notification: UIApplication.willEnterForegroundNotification) { [weak self]  _ in
            self?.locationManager.requestLocation()
        }
    }

    func updateLocation(completionBlock: @escaping  TFLLocationManagerCompletionBlock)  {
        requestLocation(using: completionBlock)
    }
}

/// MARK: Private

fileprivate extension TFLLocationManager {
    func requestLocation(using completionBlock:  TFLLocationManagerCompletionBlock?)  {
        guard self.enabled != false else {
            completionBlock?(kCLLocationCoordinate2DInvalid)
            return
        }
        guard lastKnownCoordinate == kCLLocationCoordinate2DInvalid else {
            completionBlock?(lastKnownCoordinate)
            return
        }

        self.completionBlock = completionBlock
        self.locationManager.requestLocation()
    }
}

/// MARK: CLLocationManagerDelegate

extension TFLLocationManager : CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let coordinate = locations.first?.coordinate ?? kCLLocationCoordinate2DInvalid
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
        if case CLAuthorizationStatus.authorizedWhenInUse = status {
            self.locationManager.startUpdatingLocation()
        }
    }
}
