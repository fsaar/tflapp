//
//  TFLStationDetailController.swift
//  tflapp
//
//  Created by Frank Saar on 29/05/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//

import UIKit
import Foundation
import MapKit

extension Array where Element == CLLocationCoordinate2D {
    var boundingRect : MKMapRect? {
        let latSorted = self.sorted{ $0.latitude < $1.latitude }
        let longSorted = self.sorted{ $0.longitude < $1.longitude }
        guard let minLat = latSorted.first?.latitude, let maxLat = latSorted.last?.latitude,
            let minLong = longSorted.first?.longitude, let maxLong = longSorted.last?.longitude else {
                return nil
        }
        let p1 = MKMapPoint(CLLocationCoordinate2D(latitude: minLat, longitude: minLong))
        let p2 = MKMapPoint(CLLocationCoordinate2D(latitude: maxLat, longitude: maxLong))
        let boundingMapRect = MKMapRect(x: fmin(p1.x,p2.x), y: fmin(p1.y,p2.y), width: fabs(p1.x-p2.x), height: fabs(p1.y-p2.y))
        return boundingMapRect
    }
}

class TFLStationDetailMapBusRouteOverLay : NSObject, MKOverlay {
    var coordinate: CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid
    var boundingMapRect: MKMapRect
    let model : TFLStationDetailMapViewModel
    init?(_ model : TFLStationDetailMapViewModel) {
        self.model = model
        guard let rect = model.coords.boundingRect else {
            return nil
        }
        boundingMapRect = rect
        super.init()
    }
}
