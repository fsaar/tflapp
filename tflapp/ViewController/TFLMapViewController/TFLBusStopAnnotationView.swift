//
//  TFLBusStopAnnotationView.swift
//  tflapp
//
//  Created by Frank Saar on 16/06/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//

import UIKit
import MapKit

class TFLBusStopAnnotationView: MKMarkerAnnotationView {

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        glyphText = annotation?.title ?? ""
        isEnabled = false
        glyphTintColor = .white
        markerTintColor = .red
        titleVisibility = .hidden
        displayPriority = MKFeatureDisplayPriority(rawValue: 1000)
    }
    
    @available(iOS,unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 }
