
import UIKit
import MapKit

extension CLLocationCoordinate2D {
    static func +(lhs : CLLocationCoordinate2D,rhs : CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(lhs.latitude+rhs.latitude, lhs.longitude+rhs.longitude)
    }
}

class TFLMapViewController: UIViewController,TFLChangeSetProtocol {
    @IBOutlet weak var coverView : UIView!
    @IBOutlet weak var mapView : MKMapView! = nil {
        didSet {
            mapView.delegate = self
            mapView.register(MKAnnotationView.self, forAnnotationViewWithReuseIdentifier: String(describing: MKAnnotationView.self))
        }
    }
    

    lazy var userAnnotationViewImage: UIImage = {
        let bounds = CGRect(origin:.zero, size: CGSize(width: 16, height: 16))
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(bounds: bounds,format: format)
        return renderer.image { context in
            let path = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.size.height/2)
            path.addClip()
            UIColor.white.setFill()
            path.fill()
            
            let innerBounds = bounds.insetBy(dx: 2, dy: 2)
            let innerPath = UIBezierPath(roundedRect: innerBounds, cornerRadius: innerBounds.size.height/2)
            UIColor.blue.setFill()
            innerPath.fill()
            
            let centerBounds = bounds.insetBy(dx: 6, dy: 6)
            let centerPath = UIBezierPath(roundedRect: centerBounds, cornerRadius: centerBounds.size.height/2)
            UIColor.white.setFill()
            centerPath.fill()
        }
    }()

   
    
    static fileprivate let userAnnotationIdentifier = "userAnnotationIdentifier"
    var userAnnotation = { () -> TFLMapViewAnnotation in
        let annotation = TFLMapViewAnnotation(for: kCLLocationCoordinate2DInvalid, with:TFLMapViewController.userAnnotationIdentifier)
        return annotation
    }()
    let defaultCoordinateOffset = CLLocationCoordinate2D(latitude: -1/300, longitude: 0)
    let defaultCoordinateSpan = MKCoordinateSpan(latitudeDelta: 1/300, longitudeDelta: 1/90)
    var busStopPredicationCoordinateTuple :  ([TFLBusStopArrivalsInfo], CLLocationCoordinate2D)? = nil {
        didSet (oldTuple) {
            if let busStopPredicationCoordinateTuple = self.busStopPredicationCoordinateTuple  {
                let (busStopPredictionTuples,coords) = busStopPredicationCoordinateTuple
                self.setUserAnnotationIfNeedBe(with: coords)
                
                let (inserted ,deleted ,_, _) = self.evaluateLists(oldList: oldTuple?.0 ?? [], newList: busStopPredictionTuples, compare : TFLBusStopArrivalsInfo.compare)
                
                let toBeDeletedIdentifierSet = Set(deleted.map { $0.element.identifier } )
                let toBeDeletedAnnotations = self.mapView.annotations.compactMap { $0 as? TFLMapViewAnnotation}.filter { toBeDeletedIdentifierSet.contains ($0.identifier) }
                self.mapView.removeAnnotations(toBeDeletedAnnotations)
                
                let toBeInsertedAnnotations =  inserted.map { $0.0.busStop }
                    .map { TFLMapViewAnnotation(for: $0.coord , with: $0.identifier,with: $0.name, and: $0.towards) }
                self.mapView.addAnnotations(toBeInsertedAnnotations)

                let offsetCoordinate = coords + defaultCoordinateOffset
                if CLLocationCoordinate2DIsValid(offsetCoordinate) {
                    let region = MKCoordinateRegion(center: offsetCoordinate, span: defaultCoordinateSpan)
                    let animated = (oldTuple?.0 ?? []).isEmpty   ? false : true
                    self.mapView.setRegion(region, animated: animated)
                }
                
            }
        }
    }
}

extension TFLMapViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let mapViewAnnotation = annotation as? TFLMapViewAnnotation {
            let annotationView =  self.mapView.dequeueReusableAnnotationView(withIdentifier:  String(describing: MKAnnotationView.self))
            switch mapViewAnnotation {
            case self.userAnnotation:
                annotationView?.image = self.userAnnotationViewImage
            default:
                if let (busStopPredictionTuples,_) = busStopPredicationCoordinateTuple, let stationInfo = busStopPredictionTuples.filter ({ mapViewAnnotation.identifier == $0.busStop.identifier }).first {
                    annotationView?.image = MKMapView.stationAnnotationImage(with: stationInfo.busStop.stopLetter ?? "")
                    annotationView?.centerOffset = CGPoint(x:0,y:-15)
                }
                else
                {
                     annotationView?.image = MKMapView.stationAnnotationImage(with: "X")
                }
            }
            return annotationView
        }
        return nil
    }

}

fileprivate extension TFLMapViewController {
    
    func setUserAnnotationIfNeedBe(with coordinate: CLLocationCoordinate2D) {
        
        if CLLocationCoordinate2DIsValid(self.userAnnotation.coordinate) {
            self.mapView.removeAnnotation(self.userAnnotation)
            self.userAnnotation =  TFLMapViewAnnotation(for: coordinate, with: TFLMapViewController.userAnnotationIdentifier)
            if CLLocationCoordinate2DIsValid(coordinate) {
                self.mapView.addAnnotation(userAnnotation)
            }
        }
        else
        {
            if CLLocationCoordinate2DIsValid(coordinate) {
                self.userAnnotation =  TFLMapViewAnnotation(for: coordinate, with: TFLMapViewController.userAnnotationIdentifier)
                self.mapView.addAnnotation(userAnnotation)
            }
        }
    }
}
