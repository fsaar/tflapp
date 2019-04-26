
import UIKit
import MapKit

protocol TFLMapViewControllerDelegate : class {
    func mapViewController(_ mapViewController : TFLMapViewController,didSelectStationWith identifier : String)
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
    weak var delegate : TFLMapViewControllerDelegate?
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
    fileprivate var selectableIdentifer : String?
    
    func showBusStop(with identifier : String, animated : Bool) {
        guard let busStopArrivalsInfos = busStopPredicationCoordinateTuple?.0,
            let model = busStopArrivalsInfos.first (where: { $0.identifier == identifier }) else {
            return
        }
        let coords = model.busStop.coord
        let span = MKCoordinateSpan(latitudeDelta: 1/500, longitudeDelta: 1/180)
        let region = MKCoordinateRegion(center: coords, span: span)
        selectableIdentifer = identifier
        self.mapView.setRegion(region, animated: animated)
    }
}

extension TFLMapViewController : MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        guard let identifier = selectableIdentifer else {
            return
        }
        selectableIdentifer = nil
        let annnotations = self.mapView.annotations.compactMap { $0 as? TFLMapViewAnnotation }
        guard let annotation = annnotations.first (where : {$0.identifier == identifier }),
            let annotationView = self.mapView.view(for: annotation) else {
                return
        }
        annotationView.animateCurrentPosition()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard let mapViewAnnotation = annotation as? TFLMapViewAnnotation else {
            return nil
        }
        return TFLBusStopAnnotationView(annotation: mapViewAnnotation,
                                        reuseIdentifier: String(describing: TFLBusStopAnnotationView.self)) { [weak self] mapViewAnnotation in
            guard let self = self else {
                return
            }
            self.delegate?.mapViewController(self, didSelectStationWith: mapViewAnnotation.identifier)
        }
    }

}

// MARK: Private

fileprivate extension TFLMapViewController {
    func resetStateIfMapViewHidden(_ hidden : Bool) {
        state = hidden ? .inited : self.state
    }
}
