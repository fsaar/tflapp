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
        titleVisibility = .hidden
        displayPriority = MKFeatureDisplayPriority(rawValue: 1000)
        self.layer.anchorPoint = CGPoint(x:0.5,y:1)
        self.centerOffset = CGPoint(x:0.5,y:-0.5)
        self.accessibilityLabel = accessiblityLabel(with: annotation?.arrivalsInfo) ?? annotation?.title
        self.isAccessibilityElement = true
        updateColors()
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
    
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//        guard traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle else {
//            return
//        }
//        updateColors()
//    }
 }

// MARK: - Private

extension TFLBusStopAnnotationView {
    
    func updateColors() {
        glyphTintColor =  UIColor(named: "tflAnnotationViewTextColor")
        markerTintColor = UIColor(named: "tflAnnotationViewBackgroundColor")
    }
    
    func accessiblityLabel(with arrivalsInfo : TFLBusStopArrivalsInfo?) -> String? {
        guard let busStop = arrivalsInfo?.busStop else  {
            return nil
        }
        let towardsCopy = NSLocalizedString("Common.towards", comment: "")
        
        let towards = busStop.towards?.isEmpty == false ? "\(towardsCopy) \(busStop.towards ?? "")" : ""
        guard let stopLetter = busStop.stopLetter else {
            return "\(busStop.name) \(busStop.name) \(towards)"
        }
        return "\(stopLetter) - \(busStop.name) \(towards)"
    }
}
