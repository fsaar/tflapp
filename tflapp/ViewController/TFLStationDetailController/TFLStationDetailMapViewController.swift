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

protocol TFLStationDetailMapViewControllerDelegate : AnyObject {
    func stationDetailMapViewController(_ stationDetailMapViewController : TFLStationDetailMapViewController,didSelectStationWith identifier : String)
}

class TFLStationDetailMapViewController: UIViewController {
    weak var delegate : TFLStationDetailMapViewControllerDelegate?
    fileprivate var selectableIdentifer : String?
    
    @IBOutlet weak var mapView : MKMapView! = nil {
        didSet {
            mapView.delegate = self
            mapView.register(TFLStationDetailBusStopAnnotationView.self, forAnnotationViewWithReuseIdentifier: String(describing: MKMapViewDefaultAnnotationViewReuseIdentifier.self))
            mapView.mapType = .mutedStandard
            mapView.showsUserLocation = false
            mapView.showsCompass = false
        }
    }
    fileprivate var selectedOverlayIndex : Int? = nil {
        didSet {
            if let index = self.selectedOverlayIndex,index < overlays.count {
                let overlay = overlays[index]
                let stations = overlay.model.stations
                mapView.addOverlay(overlay)
                let annotations : [TFLStationDetailMapViewAnnotation] = stations.enumerated().map { tuple in
                                                                                                    TFLStationDetailMapViewAnnotation(with: tuple.1.identifier,
                                                                                                                                      stopCode: tuple.1.stopCode,
                                                                                                                                      coordinate: tuple.1.coords,
                                                                                                                                      index: tuple.0,
                                                                                                                                      and:tuple.1.stopDescription)
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
            let mapRect = overlays.reduce(MKMapRect.null) { $0.union($1.boundingMapRect) }
            let insetRect = mapRect.insetBy(dx: -10000, dy: -10000)
            self.mapView.region = MKCoordinateRegion(insetRect)
            self.selectedOverlayIndex = 0
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
    
    func showBusStop(with identifier : String, animated : Bool) {
        guard let index = self.selectedOverlayIndex,index < overlays.count else {
            return
        }
        let overlay = overlays[index]
        let stations = overlay.model.stations
        
        guard let model = stations.first (where: { $0.identifier == identifier }) else {
                return
        }
        let coords = model.coords
        let span = MKCoordinateSpan(latitudeDelta: 1/500, longitudeDelta: 1/180)
        let region = MKCoordinateRegion(center: coords, span: span)
        selectableIdentifer = identifier
        self.mapView.setRegion(region, animated: animated)
    }
}

extension TFLStationDetailMapViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        guard let identifier = selectableIdentifer else {
            return
        }
        selectableIdentifer = nil
        let annnotations = self.mapView.annotations.compactMap { $0 as? TFLStationDetailMapViewAnnotation }
        guard let annotation = annnotations.first (where : { $0.identifier == identifier }),
            let annotationView = self.mapView.view(for: annotation) else {
                return
        }
        annotationView.animateCurrentPosition()
    }
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard let busRouteOverlay = overlay as? TFLStationDetailMapBusRouteOverLay else {
            return MKOverlayRenderer()
        }
        let coords = busRouteOverlay.model.coords
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
        let annotationView = TFLStationDetailBusStopAnnotationView(annotation: mapViewAnnotation, reuseIdentifier: String(describing: TFLStationDetailBusStopAnnotationView.self)) { [weak self] annotation in
            guard let self = self else {
                return
            }
             self.delegate?.stationDetailMapViewController(self, didSelectStationWith: annotation.identifier)
        }
        return annotationView
    }
}
