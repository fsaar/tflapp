
import UIKit
import MapKit

extension CLLocationCoordinate2D {
    static func +(lhs : CLLocationCoordinate2D,rhs : CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(lhs.latitude+rhs.latitude, lhs.longitude+rhs.longitude)
    }
}

class TFLMapViewController: UIViewController,TFLChangeSetProtocol {
    @IBOutlet weak var mapView : MKMapView! = nil {
        didSet {
            self.mapView.showsUserLocation = true
            self.mapView.showsTraffic = false
            self.mapView.showsBuildings = false
            self.mapView.showsPointsOfInterest = false
        }
    }
    let defaultCoordinateOffset = CLLocationCoordinate2D(latitude: -1/300, longitude: 0)
    let defaultCoordinateSpan = MKCoordinateSpan(latitudeDelta: 1/300, longitudeDelta: 1/90)
    var busStopPredicationCoordinateTuple :  ([TFLBusStopArrivalsInfo], CLLocationCoordinate2D)? = nil {
        didSet (oldTuple) {
            if let busStopPredicationCoordinateTuple = self.busStopPredicationCoordinateTuple  {
                let (busStopPredictionTuples,coords) = busStopPredicationCoordinateTuple
                
                let (inserted ,deleted ,_, _) = self.evaluateLists(oldList: oldTuple?.0 ?? [], newList: busStopPredictionTuples, compare : TFLBusStopArrivalsInfo.compare)
                
                let toBeDeletedIdentifierSet = Set(deleted.map { $0.element.identifier } )
                let toBeDeletedAnnotations = self.mapView.annotations.flatMap { $0 as? TFLMapViewAnnotation}.filter { toBeDeletedIdentifierSet.contains ($0.identifier) }
                self.mapView.removeAnnotations(toBeDeletedAnnotations)
                
                let toBeInsertedAnnotations =  inserted.map { $0.0.busStop }
                                                .map { TFLMapViewAnnotation(with: $0.name, and: $0.towards, for: $0.coord , with: $0.identifier) }
                self.mapView.addAnnotations(toBeInsertedAnnotations)

                let offsetCoordinate = coords + defaultCoordinateOffset
                let region = MKCoordinateRegion(center: offsetCoordinate, span: defaultCoordinateSpan)
                let animated = (oldTuple?.0 ?? []).isEmpty   ? false : true
                self.mapView.setRegion(region, animated: animated)
                
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

}

fileprivate extension TFLMapViewController {
    
}
