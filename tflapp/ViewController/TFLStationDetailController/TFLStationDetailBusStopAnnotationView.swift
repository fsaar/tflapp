//
//  TFLStationDetailBusStopAnnotationView.swift
//  tflapp
//
//  Created by Frank Saar on 16/06/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//

import UIKit
import MapKit

typealias TFLStationDetailBusStopAnnotationViewTapHandler = (_ annotation : TFLStationDetailMapViewAnnotation) -> Void


class TFLStationDetailBusStopAnnotationView: MKMarkerAnnotationView {

    var tapActionHandler : TFLStationDetailBusStopAnnotationViewTapHandler?
    init(annotation: TFLStationDetailMapViewAnnotation?, reuseIdentifier: String?,using tapActionHandler: TFLStationDetailBusStopAnnotationViewTapHandler? = nil)  {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.tapActionHandler = tapActionHandler
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        self.addGestureRecognizer(recognizer)
        
        collisionMode =  .circle
        glyphText = annotation?.title ?? ""
        isEnabled = false
        glyphTintColor = .white
        markerTintColor = .red
        titleVisibility = .hidden
        displayPriority = annotation?.priority ?? MKFeatureDisplayPriority(rawValue: 750)
        self.layer.anchorPoint = CGPoint(x:0.5,y:1)
        self.centerOffset = CGPoint(x:0.5,y:-0.5)
        self.isAccessibilityElement = true
        self.accessibilityLabel = annotation?.accessibilityString
    }

    @available(iOS,unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    func tapGestureHandler() {
        guard let mapViewAnnotation = annotation as? TFLStationDetailMapViewAnnotation else {
            return
        }
        tapActionHandler?(mapViewAnnotation)
    }
}
