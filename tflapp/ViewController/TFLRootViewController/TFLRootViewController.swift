import CoreLocation
import UIKit
import CoreData
import os.signpost


class TFLRootViewController: UIViewController {
    typealias CompletionBlock = ()->()
    fileprivate var defaultRadius : Double {
        let userDefaultRadius = UserDefaults.standard.double(forKey: "Distance")
        let searchParam = TFLRootViewController.searchParameter
        let radius = userDefaultRadius < searchParam.min ? searchParam.initial : userDefaultRadius
        return radius
    }
    fileprivate static let searchParameter  : (min:Double,initial:Double) = (100,500)
    fileprivate let networkBackgroundQueue = OperationQueue()
    fileprivate let tflClient = TFLClient()
    fileprivate let busStopDBGenerator = TFLBusStopDBGenerator()
    fileprivate static let loggingHandle  = OSLog(subsystem: TFLLogger.subsystem, category: TFLLogger.category.rootViewController.rawValue)
    lazy var busInfoAggregator = TFLBusArrivalInfoAggregator()
    lazy var debugUtility = TFLDebugUtility(with: self.view)
    
    fileprivate enum State {
        case errorNoGPSAvailable
        case errorCouldntDetermineCurrentLocation
        case errorNoStationsNearby(coordinate : CLLocationCoordinate2D)
        case determineCurrentLocation
        case retrievingNearbyStations
        case loadingArrivals
        case noError

        var isErrorState : Bool {
            switch self {
            case .errorNoGPSAvailable,.errorNoStationsNearby,.errorCouldntDetermineCurrentLocation:
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
            case .errorNoGPSAvailable,.errorNoStationsNearby,.errorCouldntDetermineCurrentLocation:
                return true
            case .noError:
                return true
            default:
                return false

            }
        }
    }
    fileprivate let defaultRefreshInterval : Int = 30
    
    fileprivate var isContentAvailable : Bool {
        return !(self.nearbyBusStationController?.busStopPredicationTuple.isEmpty ?? true)
    }
    
    fileprivate var state : State = .noError {
        didSet {
            let shouldHide = self.nearbyBusStationController?.busStopPredicationTuple.isEmpty ?? true

            switch self.state {
            case .errorNoGPSAvailable:
                self.contentView.isHidden = true
                self.errorContainerView.showNoGPSEnabledError()
            case .errorNoStationsNearby:
                self.contentView.isHidden = true
                self.errorContainerView.showNoStationsFoundError()
            case .errorCouldntDetermineCurrentLocation:
                self.contentView.isHidden = shouldHide
                if shouldHide {
                    self.errorContainerView.showNoStationsFoundError()
                }
            case .determineCurrentLocation:
                self.contentView.isHidden = shouldHide
                self.errorContainerView.showLoadingCurrentLocationIfNeedBe(isContentAvailable: isContentAvailable)
            case .retrievingNearbyStations:
                self.contentView.isHidden = shouldHide
                self.errorContainerView.showLoadingNearbyStationsIfNeedBe(isContentAvailable: isContentAvailable)
            case .loadingArrivals:
                self.contentView.isHidden = shouldHide
                self.errorContainerView.showLoadingArrivalTimesIfNeedBe(isContentAvailable: isContentAvailable)
            case .noError:
                self.errorContainerView.hideErrorViews()
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

     fileprivate lazy var nearbyBusStationController : TFLNearbyBusStationsController? =  {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: "TFLNearbyBusStationsController") as? TFLNearbyBusStationsController
        return controller
    }()
    fileprivate lazy var updateStatusView : TFLUpdateStatusView =  {
        let view = TFLUpdateStatusView(style: .detailed, refreshInterval: self.defaultRefreshInterval)
        view.delegate = self
        view.state = .updatePending
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    fileprivate var slideContainerController : TFLSlideContainerController?
    private var foregroundNotificationHandler  : TFLNotificationObserver?
    private var backgroundNotificationHandler  : TFLNotificationObserver?
    @IBOutlet weak var errorContainerView : TFLErrorContainerView! = nil {
        didSet {
            self.errorContainerView.delegate = self
        }
    }

    @IBOutlet weak var contentView : UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.slideContainerController?.rightCustomView = self.updateStatusView
        
        TFLLocationManager.sharedManager.delegate = self
        if let mapViewController = self.mapViewController, let nearbyBusStationController = self.nearbyBusStationController {
            self.slideContainerController?.setContentControllers(with: mapViewController,and: nearbyBusStationController)
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
            self?.updateStatusView.state = .updating
            let retryIfRequestWasPending = !(self?.state.isComplete ?? true)
            self?.loadNearbyBusstops {
                if retryIfRequestWasPending {
                    self?.loadNearbyBusstops()
                }
            }
        }
        self.backgroundNotificationHandler = TFLNotificationObserver(notification:UIApplication.didEnterBackgroundNotification) { [weak self]  _ in
            self?.updateStatusView.state = .paused
        }
        self.loadNearbyBusstops()
        
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
    var loadNearbyBusStopsCompletionBlocks : [CompletionBlock?] = []
}

// MARK: Private

fileprivate extension TFLRootViewController {
    
    func updateContentViewController(with arrivalsInfo: [TFLBusStopArrivalsInfo],isUpdatePending updatePending : Bool, and  coordinate: CLLocationCoordinate2D) -> Bool {
        let radius = self.defaultRadius

        let oldTuples = self.nearbyBusStationController?.busStopPredicationTuple ?? []
        var mergedInfo : [TFLBusStopArrivalsInfo] = []
    
        switch (oldTuples.isEmpty,arrivalsInfo.isEmpty) {
        case (false,false):
            mergedInfo = updatePending ? oldTuples.mergedUpdatedArrivalsInfo(arrivalsInfo) : oldTuples.mergedArrivalsInfo(arrivalsInfo)
        case (true,false):
            mergedInfo = arrivalsInfo
        case (_,true):
            let newTuples = oldTuples.map { $0.arrivalInfo(with:  coordinate.location) }
            mergedInfo = newTuples
        }
        
        let filteredArrivalsInfo = mergedInfo.filter { !$0.liveArrivals().isEmpty }.filter { $0.busStopDistance <= radius }
        self.nearbyBusStationController?.busStopPredicationTuple = filteredArrivalsInfo
        self.nearbyBusStationController?.currentUserCoordinate = coordinate
        switch (updatePending,filteredArrivalsInfo.isEmpty) {
        case (true,false):
            self.state = .loadingArrivals
            return true
        case (false,false):
            self.mapViewController?.busStopPredicationCoordinateTuple = (filteredArrivalsInfo,coordinate)
            return true
        case (true,true): // Wait til complete
            return true
        case (false,true):
            self.mapViewController?.busStopPredicationCoordinateTuple = (filteredArrivalsInfo,coordinate)
            return false
        }
    }
    

    func loadNearbyBusstops(using completionBlock:CompletionBlock? = nil) {
        objc_sync_enter(self)
        defer {
            objc_sync_exit(self)
        }
        
        loadNearbyBusStopsCompletionBlocks += [completionBlock]
        guard state.isComplete else {
            return
        }
        self.updateStatusView.state = .updating
        self.state = .determineCurrentLocation
    
        self.currentCoordinates { [weak self] coord in
            let completionBlock : (_ state : State) -> () = { [weak self] state in
                if let self = self {
                    objc_sync_enter(self)
                    let blocks = self.loadNearbyBusStopsCompletionBlocks
                    self.loadNearbyBusStopsCompletionBlocks = []
                    self.state = state
                    blocks.forEach { $0?() }
                    self.updateStatusView.state = .updatePending
                    objc_sync_exit(self)
                }
            }
            
            guard let coord = coord,coord.isValid else {
                let state : State = TFLLocationManager.sharedManager.enabled ? .errorCouldntDetermineCurrentLocation : .errorNoGPSAvailable
                completionBlock(state)
                return
            }

            self?.updateUI(with: coord) { updated in
                let state : State = updated ? .noError : .errorNoStationsNearby(coordinate: coord)
                completionBlock(state)
            }
        }
    }
    
    
    
    fileprivate func currentCoordinates(using completionBlock : @escaping (_ coord : CLLocationCoordinate2D?) -> Void) {
        TFLLocationManager.sharedManager.updateLocation { coord in
            completionBlock(coord)
        }
    }
    
    fileprivate func updateUI(with coord : CLLocationCoordinate2D, using completionBlock:@escaping (_ updated : Bool) -> ()) {
        
        _ = self.updateContentViewController(with: [],isUpdatePending: false, and: coord)
        self.retrieveBusstops(for: coord) { [weak self] busStopPredictionTuples,isComplete  in
            
            let updated = self?.updateContentViewController(with: busStopPredictionTuples, isUpdatePending: !isComplete, and: coord) ?? false
            guard isComplete else {
                return
            }
            completionBlock(updated)
        }
    }
    

    
    func retrieveBusstops(for location:CLLocationCoordinate2D, using completionBlock:@escaping ([TFLBusStopArrivalsInfo],_ completed: Bool)->()) {
        self.state = .retrievingNearbyStations
        if location.isValid {
            
            self.state = .loadingArrivals
            self.busInfoAggregator.loadArrivalTimesForStoreStopPoints(with: location,with: self.defaultRadius, using: completionBlock)
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

// MARK: TFLErrorContainerViewDelegate

extension TFLRootViewController : TFLErrorContainerViewDelegate {
    func didTap(noStationsButton: UIButton,in view : TFLNoStationsView) {
        loadNearbyBusstops ()
    }
    
    func didTap(noGPSEnabledButton: UIButton,in view : TFLNoGPSEnabledView) {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        UIApplication.shared.open(url)
    }
}


extension TFLRootViewController : TFLLocationManagerDelegate {
    func locationManager(_ locationManager : TFLLocationManager, didChangeEnabledStatus enabled : Bool) {
        guard enabled else {
            return
        }
        loadNearbyBusstops()
    }
}

// MARK: TFLContentControllerDelegate

extension TFLRootViewController : TFLNearbyBusStationsControllerDelegate  {
    func lastRefresh(of controller: TFLNearbyBusStationsController) -> Date? {
        return busInfoAggregator.lastUpdate
    }
    
    func refresh(controller: TFLNearbyBusStationsController, using completionBlock:@escaping ()->()) {
        loadNearbyBusstops (using: completionBlock)
    }
}


// MARK: TFLStatusViewDelegate

extension TFLRootViewController : TFLUpdateStatusViewDelegate {
    func didExpireTimerInStatusView(_ tflStatusView : TFLUpdateStatusView) {
        TFLLogger.shared.event(osLog: TFLRootViewController.loggingHandle, name: "refreshTimer")
        self.loadNearbyBusstops()
    }
}
