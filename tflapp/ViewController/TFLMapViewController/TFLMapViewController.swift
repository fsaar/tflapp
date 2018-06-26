
import UIKit
import MapKit

extension CLLocationCoordinate2D {
    static func +(lhs : CLLocationCoordinate2D,rhs : CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(lhs.latitude+rhs.latitude, lhs.longitude+rhs.longitude)
    }
}

class TFLMapViewController: UIViewController {
    @IBOutlet weak var coverView : UIView!
    @IBOutlet weak var mapView : MKMapView! = nil {
        didSet {
            mapView.delegate = self
            mapView.register(TFLBusStopAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
            mapView.showsUserLocation = true
        }
    }
    
    let defaultCoordinateOffset = CLLocationCoordinate2D(latitude: -1/300, longitude: 0)
    let defaultCoordinateSpan = MKCoordinateSpan(latitudeDelta: 1/300, longitudeDelta: 1/90)
    var busStopPredicationCoordinateTuple :  ([TFLBusStopArrivalsInfo], CLLocationCoordinate2D)? = nil {
        didSet (oldTuple) {
            if let busStopPredicationCoordinateTuple = self.busStopPredicationCoordinateTuple  {
                let (busStopPredictionTuples,coords) = busStopPredicationCoordinateTuple
                let oldList = oldTuple?.0 ?? []
                var (inserted ,deleted ,_, _) : (inserted : [(element:TFLBusStopArrivalsInfo,index:Int)],deleted : [(element:TFLBusStopArrivalsInfo,index:Int)], updated : [(element:TFLBusStopArrivalsInfo,index:Int)],moved : [(element:TFLBusStopArrivalsInfo,oldIndex:Int,newIndex:Int)]) = ([],[],[],[])
                DispatchQueue.global().sync {
                    (inserted ,deleted ,_, _) = oldList.transformTo(newList: busStopPredictionTuples, sortedBy : TFLBusStopArrivalsInfo.compare)
                }
                
                let toBeDeletedIdentifierSet = Set(deleted.map { $0.element.identifier } )
                let toBeDeletedAnnotations = self.mapView.annotations.compactMap { $0 as? TFLMapViewAnnotation}.filter { toBeDeletedIdentifierSet.contains ($0.identifier) }
                self.mapView.removeAnnotations(toBeDeletedAnnotations)
                
                let toBeInsertedAnnotations =  inserted.map { $0.0 }
                    .map { TFLMapViewAnnotation(with: $0) }
                self.mapView.addAnnotations(toBeInsertedAnnotations)
                
                let offsetCoordinate = coords + self.defaultCoordinateOffset
                if CLLocationCoordinate2DIsValid(offsetCoordinate) {
                    let region = MKCoordinateRegion(center: offsetCoordinate, span: self.defaultCoordinateSpan)
                    let animated = (oldTuple?.0 ?? []).isEmpty   ? false : true
                    self.mapView.setRegion(region, animated: animated)
                }
            }
        }
    }
}

extension TFLMapViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let mapViewAnnotation = annotation as? TFLMapViewAnnotation else {
            return nil
        }
        return TFLBusStopAnnotationView(annotation: mapViewAnnotation, reuseIdentifier: String(describing: TFLBusStopAnnotationView.self))
    }

}

