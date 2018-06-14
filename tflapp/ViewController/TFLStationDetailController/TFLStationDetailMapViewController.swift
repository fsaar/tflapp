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

class TFLStationDetailMapViewController: UIViewController {
    @IBOutlet weak var mapView : MKMapView! = nil {
        didSet {
            mapView.delegate = self
            mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: String(describing: MKAnnotationView.self))
        }
    }
    fileprivate var selectedOverlayIndex : Int? = nil {
        didSet {
            if let index = self.selectedOverlayIndex,index < overlays.count {
                let overlay = overlays[index]
                let stations = overlay.model.stations
                mapView.add(overlay)
                let annotations =  stations.map { TFLMapViewAnnotation(for: $0.coords, with: $0.stopCode) }
                self.mapView.addAnnotations(annotations)
            }

        }
    }
    fileprivate var overlays : [TFLStationDetailMapBusRouteOverLay] = []
    
    var viewModels : [TFLStationDetailMapViewModel] = [] {
        didSet {
            self.mapView.removeOverlays(self.mapView.overlays)
            guard !viewModels.isEmpty else {
                return
            }
            overlays = self.viewModels.compactMap { TFLStationDetailMapBusRouteOverLay($0) }
            let mapRect = overlays.reduce(MKMapRectNull) { MKMapRectUnion($0, $1.boundingMapRect) }
            let insetRect = MKMapRectInset(mapRect, -10000, -10000)
            self.mapView.region = MKCoordinateRegionForMapRect(insetRect)
        }
    }
    
    func showRouteForModel(at index: Int, animated: Bool) {
        guard index < overlays.count else {
            return
        }
        self.mapView.removeOverlays(self.mapView.overlays)
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.selectedOverlayIndex = index
    }
}

extension TFLStationDetailMapViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let busRouteOverlay = overlay as? TFLStationDetailMapBusRouteOverLay else {
            return MKOverlayRenderer()
        }
        let coords = busRouteOverlay.model.stations.map { $0.coords }
        let polyline = MKPolyline(coordinates: coords, count: coords.count)
        let renderer = MKPolylineRenderer(polyline: polyline)
        renderer.lineWidth = 2
        renderer.strokeColor = .red
        return renderer
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let mapViewAnnotation = annotation as? TFLMapViewAnnotation {
            let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier:String(describing: String(describing: MKAnnotationView.self)))
            annotationView?.image = MKMapView.stationAnnotationImage(with: mapViewAnnotation.identifier)
            annotationView?.centerOffset = CGPoint(x:0,y:-15)
            return annotationView
        }
        return nil
    }
}

