import CoreLocation
import UIKit
import CoreData
import os.signpost


class TFLRootViewController: UIViewController {
    fileprivate static let searchParameter  : (min:Double,initial:Double) = (100,350)
    fileprivate let networkBackgroundQueue = OperationQueue()
    fileprivate let tflClient = TFLClient()
    fileprivate let busStopDBGenerator = TFLBusStopDBGenerator()
    fileprivate static let loggingHandle  = OSLog(subsystem: TFLLogger.subsystem, category: TFLLogger.category.api.rawValue)
    lazy var busInfoAggregator = TFLBusArrivalInfoAggregator()
    fileprivate enum State {
        case errorNoGPSAvailable
        case errorNoStationsNearby(coordinate : CLLocationCoordinate2D)
        case determineCurrentLocation
        case retrievingNearbyStations
        case loadingArrivals
        case noError

        var isErrorState : Bool {
            switch self {
            case .errorNoGPSAvailable,.errorNoStationsNearby:
                return true
            default:
                return false

            }
        }
        var isDeterminingCurrentLocation : Bool {
            if case .determineCurrentLocation = self {
                return true
            }
            return false
        }
        var isComplete : Bool {
            switch self {
            case .errorNoGPSAvailable,.errorNoStationsNearby:
                return true
            case .noError:
                return true
            default:
                return false

            }
        }
    }
    fileprivate(set) var DefaultRefreshInterval : TimeInterval = 30

    fileprivate var state : State = .noError {
        didSet {
            let shouldHide = self.nearbyBusStationController?.busStopPredicationTuple.isEmpty ?? true

            switch self.state {
            case .errorNoGPSAvailable:
                self.contentView.isHidden = true
                showNoGPSEnabledError()
            case .errorNoStationsNearby:
                self.contentView.isHidden = true
                showNoStationsFoundError()
            case .determineCurrentLocation:
                self.contentView.isHidden = shouldHide
                showLoadingCurrentLocationIfNeedBe()
            case .retrievingNearbyStations:
                self.contentView.isHidden = shouldHide
                showLoadingNearbyStationsIfNeedBe()
            case .loadingArrivals:
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
    private var foregroundNotificationHandler  : TFLNotificationObserver?
    private var backgroundNotificationHandler  : TFLNotificationObserver?
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

    fileprivate(set) lazy var refreshTimer : TFLTimer? = {
        TFLTimer(timerInterVal: DefaultRefreshInterval) { [weak self] _ in
            TFLLogger.shared.event(osLog: TFLRootViewController.loggingHandle, name: "refreshTimer")

            self?.loadNearbyBusstops()
        }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
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
            }
            self.nearbyBusStationController?.delegate = self
        }

        self.foregroundNotificationHandler = TFLNotificationObserver(notification: UIApplication.willEnterForegroundNotification) { [weak self]  _ in
            self?.loadNearbyBusstops()
            self?.refreshTimer?.start()
        }
        self.backgroundNotificationHandler = TFLNotificationObserver(notification:UIApplication.didEnterBackgroundNotification) { [weak self]  _ in
            self?.refreshTimer?.stop()
        }
        TFLRequestManager.shared.delegate = self
        self.loadNearbyBusstops()
        self.refreshTimer?.start()
        
//        self.busStopDBGenerator.loadBusStops { [weak self] in
//            self?.busStopDBGenerator.loadLineStations()
//        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
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
    
    func updateContentViewController(with arrivalsInfo: [TFLBusStopArrivalsInfo],isUpdatePending updatePending : Bool, and  coordinate: CLLocationCoordinate2D) {
        let oldTuples = self.nearbyBusStationController?.busStopPredicationTuple ?? []
        var mergedInfo : [TFLBusStopArrivalsInfo] = []
    
        switch (oldTuples.isEmpty,arrivalsInfo.isEmpty) {
        case (false,false):
            mergedInfo = updatePending ? oldTuples.mergedUpdatedArrivalsInfo(arrivalsInfo) : oldTuples.mergedArrivalsInfo(arrivalsInfo)
        case (true,false):
            mergedInfo = arrivalsInfo
        case (_,true):
            let newTuples = oldTuples.map { $0.arrivalInfo(with:  CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) }
            mergedInfo = newTuples
        }
        
        let filteredArrivalsInfo = mergedInfo.filter { !$0.liveArrivals().isEmpty }
        self.nearbyBusStationController?.busStopPredicationTuple = filteredArrivalsInfo

        switch (updatePending,filteredArrivalsInfo.isEmpty) {
        case (true,false):
            self.state = .loadingArrivals
        case (false,false):
            self.mapViewController?.busStopPredicationCoordinateTuple = (filteredArrivalsInfo,coordinate)
            self.state = .noError
        case (true,true): // Wait til complete
            break
        case (false,true):
            self.mapViewController?.busStopPredicationCoordinateTuple = (filteredArrivalsInfo,coordinate)
            self.state = .errorNoStationsNearby(coordinate: coordinate)
        }
    }


    func loadNearbyBusstops(using completionBlock:(()->())? = nil) {
        guard state.isComplete else {
            completionBlock?()
            return
        }
        guard TFLLocationManager.sharedManager.enabled != false else {
            self.state = .errorNoGPSAvailable
            completionBlock?()
            return
        }
        self.state = .determineCurrentLocation
        TFLLocationManager.sharedManager.updateLocation { [weak self] coord in
            self?.updateContentViewController(with: [],isUpdatePending: false, and: coord)
            self?.retrieveBusstops(for: coord) { busStopPredictionTuples,isComplete  in
                
                self?.updateContentViewController(with: busStopPredictionTuples, isUpdatePending: !isComplete, and: coord)
                guard isComplete else {
                    return
                }
                completionBlock?()
            }
            
        }
    }


    func retrieveBusstops(for location:CLLocationCoordinate2D, using completionBlock:@escaping ([TFLBusStopArrivalsInfo],_ completed: Bool)->()) {
        self.state = .retrievingNearbyStations
        if CLLocationCoordinate2DIsValid(location) {
            let userDefaultRadius = UserDefaults.standard.double(forKey: "Distance")
            let searchParam = TFLRootViewController.searchParameter
            let radius = userDefaultRadius < searchParam.min ? searchParam.initial : userDefaultRadius
            self.state = .loadingArrivals
            self.busInfoAggregator.loadArrivalTimesForStoreStopPoints(with: location,with: radius, using: completionBlock)
            self.updateNearbyBusStops(for: location)
        }
        else
        {
            self.state = .errorNoGPSAvailable
            completionBlock([],true)
        }
    }

    func updateNearbyBusStops(for currentLocation:CLLocationCoordinate2D ) {
       self.tflClient.nearbyBusStops(with: currentLocation,with: self.networkBackgroundQueue)
      
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
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        UIApplication.shared.open(url)
    }
}

// MARK: TFLNoStationsViewDelegate

extension TFLRootViewController : TFLNoStationsViewDelegate {
    func didTap(noStationsButton: UIButton,in view : TFLNoStationsView) {
        loadNearbyBusstops ()
    }
}


// MARK: TFLContentControllerDelegate

extension TFLRootViewController : TFLNearbyBusStationsControllerDelegate  {
    func refresh(controller: TFLNearbyBusStationsController, using completionBlock:@escaping ()->()) {
        loadNearbyBusstops (using: completionBlock)
    }
}

// MARK: TFLRequestManagerDelegate

extension TFLRootViewController : TFLRequestManagerDelegate {
    func didStartURLTask(with requestManager: TFLRequestManager,session : URLSession)
    {
        OperationQueue.main.addOperation {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }

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
