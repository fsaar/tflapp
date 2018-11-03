
import UIKit
import MapKit

extension CLLocationCoordinate2D {
    static func +(lhs : CLLocationCoordinate2D,rhs : CLLocationCoordinate2D) -> CLLocationCoordinate2D {
        return CLLocationCoordinate2DMake(lhs.latitude+rhs.latitude, lhs.longitude+rhs.longitude)
    }
}

class TFLMapViewController: UIViewController {
    enum MapState {
        case inited
        case userInteracted
    }
    @IBOutlet var userTrackingContainerView : UIView! {
        didSet {
            self.userTrackingContainerView.addSubview(self.userTrackingButton)
            
            NSLayoutConstraint.activate([
                self.userTrackingButton.centerXAnchor.constraint(equalTo: self.userTrackingContainerView.centerXAnchor),
                self.userTrackingButton.centerYAnchor.constraint(equalTo: self.userTrackingContainerView.centerYAnchor),
                ])

        }
    }
    
  
    @IBOutlet var visualEffectsViews : UIVisualEffectView! {
        didSet {
            self.visualEffectsViews.clipsToBounds = true
            self.visualEffectsViews.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.2).cgColor
            self.visualEffectsViews.layer.borderWidth = 1
            self.visualEffectsViews.layer.cornerRadius = 5
        }
    }
    
    fileprivate var state : MapState = .inited
    @IBOutlet weak var coverView : UIView!
    @IBOutlet weak var mapView : MKMapView! = nil {
        didSet {
            let windowFrame = (UIApplication.shared.delegate as? AppDelegate)?.window?.frame ?? CGRect.zero
            let botttomMargin = windowFrame.size.height / 2
            mapView.layoutMargins = UIEdgeInsets(top:0, left:0,bottom:botttomMargin,right:0)
            mapView.delegate = self
            mapView.showsCompass = false
            mapView.register(TFLBusStopAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
            mapView.showsUserLocation = true
        }
    }

    let defaultCoordinateSpan = MKCoordinateSpan(latitudeDelta: 1/300, longitudeDelta: 1/90)
    let mapViewUpdateQueue : OperationQueue = {
        let q = OperationQueue()
        q.maxConcurrentOperationCount = 1
        q.underlyingQueue = DispatchQueue.global()
        return q
    }()
    fileprivate let synchroniser =  TFLSynchroniser(tag: "com.samedialabs.queue.mapView")

    var busStopPredicationCoordinateTuple :  ([TFLBusStopArrivalsInfo], CLLocationCoordinate2D)? = nil {
        didSet (oldTuple) {
            synchroniser.synchronise { synchroniseEnd in
            if let busStopPredicationCoordinateTuple = self.busStopPredicationCoordinateTuple  {
                    let (busStopPredictionTuples,coords) = busStopPredicationCoordinateTuple
                    let oldList = oldTuple?.0 ?? []
                    var (inserted ,deleted ,_, _) : (inserted : [(element:TFLBusStopArrivalsInfo,index:Int)],
                        deleted : [(element:TFLBusStopArrivalsInfo,index:Int)],
                        updated : [(element:TFLBusStopArrivalsInfo,index:Int)],
                        moved : [(element:TFLBusStopArrivalsInfo,oldIndex:Int,newIndex:Int)]) = ([],[],[],[])
                    (inserted ,deleted ,_, _) = oldList.transformTo(newList: busStopPredictionTuples, sortedBy : TFLBusStopArrivalsInfo.compare)
                    DispatchQueue.main.async {
                        let toBeDeletedIdentifierSet = Set(deleted.map { $0.element.identifier } )
                        let toBeDeletedAnnotations = self.mapView.annotations.compactMap { $0 as? TFLMapViewAnnotation }.filter { toBeDeletedIdentifierSet.contains ($0.identifier) }
                        self.mapView.removeAnnotations(toBeDeletedAnnotations)
                        
                        let toBeInsertedAnnotations =  inserted.map { $0.0 }
                            .map { TFLMapViewAnnotation(with: $0) }
                        self.mapView.addAnnotations(toBeInsertedAnnotations)
                        
                        if case .inited = self.state, coords.isValid {
                            let region = MKCoordinateRegion(center: coords, span: self.defaultCoordinateSpan)
                            let animated = (oldTuple?.0 ?? []).isEmpty   ? false : true
                            self.mapView.setRegion(region, animated: animated)
                        }
                        synchroniseEnd()
                    }
                }
            }
            
        }
    }

    private var observer : NSKeyValueObservation?
    private var backgroundNotificationHandler : TFLNotificationObserver?
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.state = .userInteracted
    }
    
    fileprivate lazy var userTrackingButton : MKUserTrackingButton = {
        let button = MKUserTrackingButton(mapView: self.mapView)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = UIColor.red
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observer = self.mapView.observe(\.isHidden,options: [.new]) { [weak self]  _,change in
            self?.resetStateIfMapViewHidden(change.newValue ?? false)
        }
        
        self.backgroundNotificationHandler = TFLNotificationObserver(notification:UIApplication.didEnterBackgroundNotification) { [weak self]  _ in
            self?.state = .inited
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

// MARK: Private

fileprivate extension TFLMapViewController {
    func resetStateIfMapViewHidden(_ hidden : Bool) {
        state = hidden ? .inited : self.state
    }
}
