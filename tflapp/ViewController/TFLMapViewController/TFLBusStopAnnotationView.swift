//
//  TFLBusStopAnnotationView.swift
//  tflapp
//
//  Created by Frank Saar on 16/06/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//

import UIKit
import MapKit

typealias TFLBusStopAnnotationViewTapHandler = (_ annotation : TFLMapViewAnnotation) -> Void

class TFLBusStopAnnotationView: MKMarkerAnnotationView {
    
    var tapActionHandler : TFLBusStopAnnotationViewTapHandler?
    init(annotation: TFLMapViewAnnotation?, reuseIdentifier: String?,using tapActionHandler: TFLBusStopAnnotationViewTapHandler? = nil) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.tapActionHandler = tapActionHandler
        let recognizer = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        self.addGestureRecognizer(recognizer)
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
    
    @objc
    func tapGestureHandler() {
        guard let mapViewAnnotation = annotation as? TFLMapViewAnnotation else {
            return
        }
        tapActionHandler?(mapViewAnnotation)
    }
 }
