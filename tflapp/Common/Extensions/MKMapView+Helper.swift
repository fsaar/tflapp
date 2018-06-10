//
//  MKMap+Helper.swift
//  tflapp
//
//  Created by Frank Saar on 10/06/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//

import UIKit
import MapKit

extension MKMapView {
    static let stationlabel = { () -> UILabel in
        let label = UILabel()
        label.autoresizingMask = []
        label.numberOfLines = 1
        label.backgroundColor = .clear
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.tflFontMapBusStationIdentifier()
        return label
    }()
    
    static func stationAnnotationImage(with stopCode: String) -> UIImage {
        let bounds = CGRect(origin:.zero, size: CGSize(width: 20, height: 30))
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(bounds: bounds,format: format)
        return renderer.image { context in
            MKMapView.stationAnnotationBackgroundImage.draw(in: bounds)
            if !stopCode.isEmpty {
                let label = MKMapView.stationlabel
                label.text = stopCode
                label.frame = CGRect(x:2,y:1,width:16,height:18)
                label.drawText(in: label.frame)
                
            }
        }
    }
    
    static var stationAnnotationBackgroundImage: UIImage = {
        let bounds = CGRect(origin:.zero, size: CGSize(width: 20, height: 30))
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(bounds: bounds,format: format)
        return renderer.image { context in
            let upperBounds =  CGRect(origin:.zero, size: CGSize(width: 20, height: 20))
            let path = UIBezierPath(roundedRect:upperBounds,cornerRadius:5)
            UIColor.white.setFill()
            path.fill()
            
            let innerBounds = upperBounds.insetBy(dx: 1, dy: 1)
            let innerPath = UIBezierPath(roundedRect: innerBounds,cornerRadius:5)
            UIColor.red.setFill()
            innerPath.fill()
            
            let lowerBounds = CGRect(x:9,y:18,width:2,height:10)
            let lowerPath = UIBezierPath(rect: lowerBounds)
            UIColor.red.setFill()
            UIColor.red.setStroke()
            lowerPath.stroke()
            lowerPath.fill()
        }
    }()
}
