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
        titleVisibility = .hidden
        displayPriority = annotation?.priority ?? MKFeatureDisplayPriority(rawValue: 750)
        self.layer.anchorPoint = CGPoint(x:0.5,y:1)
        self.centerOffset = CGPoint(x:0.5,y:-0.5)
        self.isAccessibilityElement = true
        self.accessibilityLabel = annotation?.accessibilityString
        self.accessibilityTraits = [.staticText,.button]
        updateColors()
    }

    @available(iOS,unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle else {
            return
        }
        updateColors()
    }

    @objc
    func tapGestureHandler() {
        guard let mapViewAnnotation = annotation as? TFLStationDetailMapViewAnnotation else {
            return
        }
        tapActionHandler?(mapViewAnnotation)
    }
}

// MARK: - Private

extension TFLStationDetailBusStopAnnotationView {
    func updateColors() {
        glyphTintColor =  UIColor(named: "tflAnnotationViewTextColor")
        markerTintColor = UIColor(named: "tflAnnotationViewBackgroundColor")

    }
}
