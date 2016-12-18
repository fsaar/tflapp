
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
            self.mapView.delegate = self
        }
    }
    
    static let stationlabel = { () -> UILabel in
        let label = UILabel()
        label.autoresizingMask = []
        label.numberOfLines = 1
        label.backgroundColor = .clear
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.tflBoldFont(size: 10)
        return label
    }()

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
    
    static fileprivate let userAnnotationIdentifier = "userAnnotationIdentifier"
    var userAnnotation = { () -> TFLMapViewAnnotation in
        let annotation = TFLMapViewAnnotation(with: "", and: "", for: kCLLocationCoordinate2DInvalid, with:TFLMapViewController.userAnnotationIdentifier)
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
                let toBeDeletedAnnotations = self.mapView.annotations.flatMap { $0 as? TFLMapViewAnnotation}.filter { toBeDeletedIdentifierSet.contains ($0.identifier) }
                self.mapView.removeAnnotations(toBeDeletedAnnotations)
                
                let toBeInsertedAnnotations =  inserted.map { $0.0.busStop }
                                                .map { TFLMapViewAnnotation(with: $0.name, and: $0.towards, for: $0.coord , with: $0.identifier) }
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
            let annotationView = self.annotationView(with: mapViewAnnotation)
            
            switch mapViewAnnotation {
            case self.userAnnotation:
                annotationView.image = self.userAnnotationViewImage
            default:
                if let (busStopPredictionTuples,_) = busStopPredicationCoordinateTuple, let stationInfo = busStopPredictionTuples.filter ({ mapViewAnnotation.identifier == $0.busStop.identifier }).first {
                    annotationView.image = self.stationAnnotationImage(with: stationInfo.busStop.stopLetter)
                    annotationView.centerOffset = CGPoint(x:0,y:-15)
                }
                else
                {
                     annotationView.image = self.stationAnnotationImage(with: "X")
                }
            }
            return annotationView
        }
        return nil
    }

}

fileprivate extension TFLMapViewController {
    func stationAnnotationImage(with stopCode: String) -> UIImage {
        let bounds = CGRect(origin:.zero, size: CGSize(width: 20, height: 30))
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(bounds: bounds,format: format)
        return renderer.image { context in
            TFLMapViewController.stationAnnotationBackgroundImage.draw(in: bounds)
            if !stopCode.isEmpty {
                let label = TFLMapViewController.stationlabel
                label.text = stopCode
                label.frame = CGRect(x:2,y:1,width:16,height:18)
                label.drawText(in: label.frame)
                
            }
        }
    }
    
    func annotationView(with annotation: TFLMapViewAnnotation) -> MKAnnotationView {
        let annotationView =  self.mapView.dequeueReusableAnnotationView(withIdentifier: annotation.identifier) ??
            MKAnnotationView(annotation: annotation, reuseIdentifier: annotation.identifier)
        annotationView.annotation = annotation
        return annotationView
    }
    

    func setUserAnnotationIfNeedBe(with coordinate: CLLocationCoordinate2D) {
        
        if CLLocationCoordinate2DIsValid(self.userAnnotation.coordinate) {
            self.mapView.removeAnnotation(self.userAnnotation)
            self.userAnnotation =  TFLMapViewAnnotation(with : "",and : "",for: coordinate, with: TFLMapViewController.userAnnotationIdentifier)
            if CLLocationCoordinate2DIsValid(coordinate) {
                self.mapView.addAnnotation(userAnnotation)
            }
        }
        else
        {
            if CLLocationCoordinate2DIsValid(coordinate) {
                self.userAnnotation =  TFLMapViewAnnotation(with : "",and : "",for: coordinate, with: TFLMapViewController.userAnnotationIdentifier)
                self.mapView.addAnnotation(userAnnotation)
            }
        }
    }
}
