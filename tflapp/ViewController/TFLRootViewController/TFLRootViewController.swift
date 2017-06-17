import CoreLocation
import UIKit
import CoreData
import Crashlytics


class TFLRootViewController: UIViewController {
    fileprivate enum State {
        case errorNoGPSAvailable
        case errorNoStationsNearby(coordinate : CLLocationCoordinate2D)
        case determineCurrentLocation
        case retrievingNearbyStations
        case loadingArrivals
        case noError
    }

    fileprivate var state : State = .noError {
        didSet {
            let shouldHide = self.nearbyBusStationController?.busStopPredicationTuple.isEmpty ?? true

            switch self.state {
            case State.errorNoGPSAvailable:
                Crashlytics.notify()
                self.contentView.isHidden = true
                showNoGPSEnabledError()
            case State.errorNoStationsNearby(let coord):
                Crashlytics.log("no stations for coordinate (lat,long):(\(coord.latitude),\(coord.longitude))")
                self.contentView.isHidden = true
                showNoStationsFoundError()
            case State.determineCurrentLocation:
                self.contentView.isHidden = shouldHide
                showLoadingCurrentLocationIfNeedBe()
            case State.retrievingNearbyStations:
                self.contentView.isHidden = shouldHide
                showLoadingNearbyStationsIfNeedBe()
            case State.loadingArrivals:
                self.contentView.isHidden = shouldHide
                showLoadingArrivalTimesIfNeedBe()
            case State.noError:
                hideInfoViews()
                self.contentView.isHidden = false
            }
        }
    }
    private enum SegueIdentifier : String {
        case slideContainerController = "TFLSlideContainerControllerSegue"
    }
    fileprivate lazy var mapViewController : TFLMapViewController? = {
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "TFLMapViewController") as? TFLMapViewController else {
            return nil
        }
        return controller
    }()
    
    fileprivate var nearbyBusStationController : TFLNearbyBusStationsController? {
        return self.nearbyBackgroundController?.nearbyBusStationController
    }
    
    fileprivate lazy var nearbyBackgroundController : TFLNearbyBackgroundController? = {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "TFLNearbyBackgroundController") as? TFLNearbyBackgroundController
        return controller
    }()

    fileprivate var slideContainerController : TFLSlideContainerController?
    fileprivate let tflClient = TFLClient()
    private var foregroundNotificationHandler  : TFLNotificationObserver?
    @IBOutlet weak var noGPSEnabledView : TFLNoGPSEnabledView! = nil {
        didSet {
            self.noGPSEnabledView.delegate = self
        }
    }
    @IBOutlet weak var loadArrivalTimesView : TFLLoadArrivalTimesView!
    @IBOutlet weak var noStationsView : TFLNoStationsView! = nil {
        didSet {
            self.noStationsView.delegate = self
        }
    }
    @IBOutlet weak var loadLocationsView : TFLLoadLocationView!
    @IBOutlet weak var loadNearbyStationsView : TFLLoadNearbyStationsView!
    @IBOutlet weak var contentView : UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Crashlytics.notify()
        self.navigationController?.navigationBar.isHidden = true
        if let mapViewController = self.mapViewController, let nearbyBackgroundController = self.nearbyBackgroundController {
            self.slideContainerController?.setContentControllers(with: mapViewController,and: nearbyBackgroundController)
            self.slideContainerController?.sliderViewUpdateBlock =  { [weak self] slider, origin,final in
                func opacity(for y: CGFloat) -> CGFloat {
                    let y0 : CGFloat = 0.3 * (self?.view.frame.size.height ?? 0)
                    guard y < y0 else {
                        return 0
                    }
                    let baseOpacity : CGFloat = 0.25
                    let opacity = (-baseOpacity) * y/y0 + baseOpacity
                    return opacity
                }
                self?.mapViewController?.coverView.alpha = opacity(for: origin.y)
                if (final)
                {
                    Answers.logCustomEvent(withName: Answers.TFLEventType.mapSlider.rawValue, customAttributes: nil)
                }
            }
            self.nearbyBusStationController?.delegate = self
        }
        self.foregroundNotificationHandler = TFLNotificationObserver(notification: NSNotification.Name.UIApplicationWillEnterForeground.rawValue) { [weak self]  notification in
            self?.loadNearbyBusstops()
        }
        TFLRequestManager.sharedManager.delegate = self
        self.loadNearbyBusstops()
        

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier , let segueIdentifier = SegueIdentifier(rawValue: identifier) else {
            return
        }
        switch segueIdentifier {
        case .slideContainerController:
            if let slideContainerController = segue.destination as? TFLSlideContainerController {
                self.slideContainerController = slideContainerController
            }
        }
    }

}


// MARK: Private

fileprivate extension TFLRootViewController {
    func updateContentViewController(with arrivalsInfo: [TFLBusStopArrivalsInfo], and coordinate: CLLocationCoordinate2D) {
        let filteredArrivalsInfo = arrivalsInfo.filter { !$0.arrivals.isEmpty }
        self.state = filteredArrivalsInfo.isEmpty ? .errorNoStationsNearby(coordinate: coordinate) : .noError

        self.nearbyBusStationController?.busStopPredicationTuple = filteredArrivalsInfo
        self.mapViewController?.busStopPredicationCoordinateTuple = (filteredArrivalsInfo,coordinate)
    }
    
    
    func loadNearbyBusstops(using completionBlock:(()->())? = nil) {
        Crashlytics.notify()
        self.state = .determineCurrentLocation
        TFLLocationManager.sharedManager.updateLocation { [weak self] coord in
            self?.retrieveBusstops(for: coord) { busStopPredictionTuples in
                self?.updateContentViewController(with: busStopPredictionTuples, and: coord)
                completionBlock?()
            }
        }
    }
    
  
    func retrieveBusstops(for location:CLLocationCoordinate2D, using completionBlock:@escaping ([TFLBusStopArrivalsInfo])->()) {
        self.state = .retrievingNearbyStations
        if CLLocationCoordinate2DIsValid(location) {
            self.loadArrivalTimesForStoreStopPoints(with: location, using: completionBlock)
            self.updateNearbyBusStops(for: location)
        }
        else
        {
            self.state = .errorNoGPSAvailable
            completionBlock([])
        }
    }
    
    func updateNearbyBusStops(for currentLocation:CLLocationCoordinate2D ) {
        self.tflClient.nearbyBusStops(with: currentLocation) { _  in
            Crashlytics.notify()
        }
    }
    
    func loadArrivalTimesForStoreStopPoints(with coord: CLLocationCoordinate2D, using completionBlock:@escaping ([TFLBusStopArrivalsInfo])->()) {
        Crashlytics.notify()
        self.state = .loadingArrivals
        let currentLocation = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        let group = DispatchGroup()
        var newStopPoints : [TFLBusStopArrivalsInfo] = []
        TFLBusStopStack.sharedDataStack.nearbyBusStops(with: coord).forEach { [weak self] stopPoint in
            group.enter()
            self?.tflClient.arrivalsForStopPoint(with: stopPoint.identifier) { predictions,_ in
                let distance = currentLocation.distance(from: CLLocation(latitude: stopPoint.coord.latitude, longitude: stopPoint.coord.longitude))
                let tuple = TFLBusStopArrivalsInfo(busStop: stopPoint, busStopDistance: distance, arrivals: predictions ?? [])
                newStopPoints += [tuple]
                group.leave()
            }
        }
        group.notify(queue: DispatchQueue.main) {
            let sortedStopPoints = newStopPoints.sorted { $0.busStopDistance < $1.busStopDistance }
            completionBlock(sortedStopPoints)
            Crashlytics.notify()
        }
    }
}

// MARK: Info View Handling

fileprivate extension TFLRootViewController {

    func hideInfoViews() {
        self.noGPSEnabledView.isHidden = true
        self.loadArrivalTimesView.isHidden = true
        self.noStationsView.isHidden = true
        self.loadLocationsView.isHidden = true
        self.loadNearbyStationsView.isHidden = true
    }
    
    func showNoGPSEnabledError() {
        hideInfoViews()
        noGPSEnabledView.isHidden = false
    }

    func showNoStationsFoundError() {
        hideInfoViews()
        noStationsView.isHidden = false
    }

    func showLoadingArrivalTimesIfNeedBe() {
        hideInfoViews()
        loadArrivalTimesView.isHidden = isContentAvailable()
    }

    func showLoadingCurrentLocationIfNeedBe() {
        hideInfoViews()
        loadLocationsView.isHidden = isContentAvailable()
    }

    func showLoadingNearbyStationsIfNeedBe() {
        hideInfoViews()
        loadNearbyStationsView.isHidden = isContentAvailable()
    }
    
    func isContentAvailable() -> Bool {
        return !(self.nearbyBusStationController?.busStopPredicationTuple.isEmpty ?? true)
    }
}

// MARK: TFLNoGPSEnabledViewDelegate

extension TFLRootViewController : TFLNoGPSEnabledViewDelegate {
    func didTap(noGPSEnabledButton: UIButton,in view : TFLNoGPSEnabledView) {
        Crashlytics.notify()
        guard let url = URL(string: UIApplicationOpenSettingsURLString) else {
            return
        }
        UIApplication.shared.open(url)
    }
}

// MARK: TFLNoStationsViewDelegate

extension TFLRootViewController : TFLNoStationsViewDelegate {
    func didTap(noStationsButton: UIButton,in view : TFLNoStationsView) {
        Crashlytics.notify()
        loadNearbyBusstops ()
    }
}


fileprivate extension TFLRootViewController {
    
    // MARK: DataBase Generation
    func loadBusStops(of page: UInt = 0) {
        self.tflClient.busStops(with: page) { [weak self] busStops,_ in
            if let busStops = busStops, !busStops.isEmpty {
                print (page)
                self?.loadBusStops(of: page+1)
            }
            let context = TFLCoreDataStack.sharedDataStack.privateQueueManagedObjectContext
            context.perform {
                try? context.save()
            }
        }
    }
    
    func startSim(tuple : (counter:Double,up:Bool) = (0,true) ) {
        let coords = CLLocationCoordinate2D(latitude: 51.556700, longitude: -0.102136)
        _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
            self?.state = .determineCurrentLocation
            let coords = CLLocationCoordinate2D(latitude: coords.latitude, longitude: coords.longitude + tuple.counter * 0.001)
            self?.retrieveBusstops(for: coords) { busStopPredictionTuples in
                self?.updateContentViewController(with: busStopPredictionTuples, and: coords)
                switch tuple {
                case (30,_):
                    self?.startSim(tuple: (tuple.counter-1,false))
                case (0,_):
                    self?.startSim(tuple: (tuple.counter+1,true))
                default:
                    self?.startSim(tuple: (tuple.up ? tuple.counter+1 : tuple.counter-1,tuple.up))
                }
            }
        }
    }
}

// MARK: TFLContentControllerDelegate

extension TFLRootViewController : TFLNearbyBusStationsControllerDelegate  {
    func refresh(controller: TFLNearbyBusStationsController, using completionBlock:@escaping ()->()) {
        Crashlytics.notify()
        
        Answers.logCustomEvent(withName: Answers.TFLEventType.refresh.rawValue, customAttributes: nil)
        loadNearbyBusstops (using: completionBlock)
    }
}

// MARK: TFLRequestManagerDelegate

extension TFLRootViewController : TFLRequestManagerDelegate {
    func didStartURLTask(with requestManager: TFLRequestManager,session : URLSession)
    {
       UIApplication.shared.isNetworkActivityIndicatorVisible = true

    }
    func didFinishURLTask(with requestManager: TFLRequestManager,session : URLSession)
    {
        session.getAllTasks { tasks in
            OperationQueue.main.addOperation {
                UIApplication.shared.isNetworkActivityIndicatorVisible = !tasks.isEmpty
            }
        }
    }

}




