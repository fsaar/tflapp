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
            mapView.register(TFLStationDetailBusStopAnnotationView.self, forAnnotationViewWithReuseIdentifier: String(describing: MKMapViewDefaultAnnotationViewReuseIdentifier.self))
            mapView.mapType = .mutedStandard
            mapView.showsUserLocation = false
        }
    }
    fileprivate var selectedOverlayIndex : Int? = nil {
        didSet {
            if let index = self.selectedOverlayIndex,index < overlays.count {
                let overlay = overlays[index]
                let stations = overlay.model.stations
                mapView.add(overlay)
                var annotations : [TFLStationDetailMapViewAnnotation] = []
                for tuple in stations.enumerated() {
                    annotations += [TFLStationDetailMapViewAnnotation(with: tuple.1.stopCode, coordinate: tuple.1.coords, and: tuple.0)]
                }
    
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
        guard let mapViewAnnotation = annotation as? TFLStationDetailMapViewAnnotation else {
            return nil
        }
       
        return TFLStationDetailBusStopAnnotationView(annotation: mapViewAnnotation, reuseIdentifier: String(describing: TFLStationDetailBusStopAnnotationView.self))
    }
}

