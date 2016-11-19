import CoreLocation
import Foundation

typealias TFLLocationManagerCompletionBlock  = (CLLocationCoordinate2D)->(Void)

class TFLLocationManager : NSObject {
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
        if case .none = self.enabled {
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func updateLocation(completionBlock: @escaping  TFLLocationManagerCompletionBlock)  {
        requestLocation(using: completionBlock)
    }
}

/// MARK: Private

extension TFLLocationManager {
    func requestLocation(using completionBlock:  TFLLocationManagerCompletionBlock?)  {
        guard self.enabled != false else {
            completionBlock?(kCLLocationCoordinate2DInvalid)
            return
        }
        self.locationManager.startUpdatingLocation()
        self.completionBlock = completionBlock
    }
}


extension TFLLocationManager : CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let coordinate = locations.first?.coordinate ?? kCLLocationCoordinate2DInvalid
        DispatchQueue.main.async {
            self.completionBlock?(coordinate)
            self.completionBlock = nil
            self.locationManager.stopUpdatingLocation()
        }
    }
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.completionBlock?(kCLLocationCoordinate2DInvalid)
            self.completionBlock = nil
            self.locationManager.stopUpdatingLocation()
        }
    }
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.locationManager.stopUpdatingLocation()
        requestLocation(using: self.completionBlock)
    }
}



