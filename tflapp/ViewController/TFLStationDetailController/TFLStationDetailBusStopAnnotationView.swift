//
//  TFLStationDetailBusStopAnnotationView.swift
//  tflapp
//
//  Created by Frank Saar on 16/06/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//

import UIKit
import MapKit

class TFLStationDetailBusStopAnnotationView: MKMarkerAnnotationView {

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        var priority = MKFeatureDisplayPriority(rawValue: 750)
        if let annotation = annotation as? TFLStationDetailMapViewAnnotation {
            priority = annotation.priority
        }
        collisionMode =  .circle
        glyphText = annotation?.title ?? ""
        isEnabled = false
        glyphTintColor = .white
        markerTintColor = .red
        titleVisibility = .hidden
        displayPriority = priority
    }

    @available(iOS,unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }



}
