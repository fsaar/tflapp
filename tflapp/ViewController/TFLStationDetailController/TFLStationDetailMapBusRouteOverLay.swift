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

class TFLStationDetailMapBusRouteOverLay : NSObject, MKOverlay {
    var coordinate: CLLocationCoordinate2D = kCLLocationCoordinate2DInvalid
    var boundingMapRect: MKMapRect
    let model : TFLStationDetailMapViewModel
    init?(_ model : TFLStationDetailMapViewModel) {
        let coords = model.stations.map { $0.coords }
        let latSorted = coords.sorted { $0.latitude < $1.latitude }
        let longSorted = coords.sorted { $0.longitude < $1.longitude }
        guard let minLat = latSorted.first?.latitude, let maxLat = latSorted.last?.latitude,
            let minLong = longSorted.first?.longitude, let maxLong = longSorted.last?.longitude else {
                return nil
        }
        self.model = model
        let p1 = MKMapPointForCoordinate(CLLocationCoordinate2D(latitude: minLat, longitude: minLong))
        let p2 = MKMapPointForCoordinate(CLLocationCoordinate2D(latitude: maxLat, longitude: maxLong))

        boundingMapRect = MKMapRectMake(fmin(p1.x,p2.x), fmin(p1.y,p2.y), fabs(p1.x-p2.x), fabs(p1.y-p2.y))

    }
}


