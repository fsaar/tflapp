import CoreLocation
import UIKit
import CoreData
import os.signpost
import Network

class TFLRootViewController: UIViewController {
    typealias CompletionBlock = ()->()
    @Settings(key: .distance,defaultValue: TFLRootViewController.searchParameter.max) fileprivate var settingDistance : Double
    fileprivate  var defaultRadius : Double {
        let searchParam = TFLRootViewController.searchParameter
        let radius = settingDistance < searchParam.min ? TFLRootViewController.searchParameter.max : settingDistance
        return radius
    }
    @IBOutlet weak var containerViewBottomConstraint : NSLayoutConstraint!
    @IBOutlet weak var splashScreenContainerView : UIView!
    @IBOutlet weak var offlineView : UIView!
    fileprivate static let searchParameter  : (min:Double,max:Double) = (100,500)
    fileprivate let networkBackgroundQueue = OperationQueue()
    fileprivate let tflClient = TFLClient()
    #if DATABASEGENERATION
    fileprivate let busStopDBGenerator = TFLBusStopDBGenerator()
    #endif
    fileprivate static let loggingHandle  = OSLog(subsystem: TFLLogger.subsystem, category: TFLLogger.category.rootViewController.rawValue)
    fileprivate lazy var busInfoAggregator = TFLBusArrivalInfoAggregator()
  
    fileprivate lazy var networkMonitor : NWPathMonitor = {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] path in
            let isOffline = path.status != .satisfied
            self?.showOfflineView(isOffline)
        }
        return monitor
    }()
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
        
        var errorView : TFLErrorContainerView.ErrorView? {
            switch self {
            case .errorNoGPSAvailable:
                return .noGPSAvailable
            case .errorNoStationsNearby:
                return .noStationsNearby
            case .errorCouldntDetermineCurrentLocation:
                return .noStationsNearby
            case .determineCurrentLocation:
                return .determineCurrentLocation
            case .retrievingNearbyStations:
                return .loadingNearbyStations
            case .loadingArrivals:
                return .loadingArrivals
            case .noError:
                return nil
            }
        }
    }
    fileprivate let defaultRefreshInterval : Int = 30
    
    fileprivate var state : State = .noError {
        
        didSet {
            OperationQueue.main.addOperation {
                let shouldHide = self.nearbyBusStationController?.arrivalsInfo.isEmpty ?? true
                switch self.state.errorView {
                case .noGPSAvailable:
                    self.contentView.isHidden = true
                    self.errorContainerView.showErrorView(.noGPSAvailable)
                case let errorView?:
                    self.contentView.isHidden = shouldHide
                    if shouldHide {
                        self.errorContainerView.showErrorView(errorView)
                    }
                case .none:
                    self.contentView.isHidden = false
                    self.errorContainerView.hideErrorViews()
                }
            }
           
        }
    }
    private enum SegueIdentifier : String {
        case slideContainerController = "TFLSlideContainerControllerSegue"
        case splashViewController = "TFLSplashscreenControllerSegue"
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
    fileprivate var splashScreenController : TFLSplashscreenController?
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
        self.networkMonitor.start(queue: .main)
        self.mapViewController?.delegate = nearbyBusStationController
        self.slideContainerController?.rightCustomView = self.updateStatusView
        setupBackSwipe()

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
            guard let self = self else {
                return
            }
            self.updateStatusView.state = .updating
            Task {
               
                await self.loadNearbyBusstops()
            }
        }
        self.backgroundNotificationHandler = TFLNotificationObserver(notification:UIApplication.didEnterBackgroundNotification) { [weak self]  _ in
            self?.updateStatusView.state = .paused
        }
        #if DATABASEGENERATION
        self.busStopDBGenerator.loadBusStops { [weak self] in
            self?.busStopDBGenerator.loadLineStations()
        }
        #else
        Task {
            await self.loadNearbyBusstops()
        }
        #endif

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        hideSplashscreenIfNeedBe()
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
        case .splashViewController:
            if let controller = segue.destination as? TFLSplashscreenController {
                self.splashScreenController = controller
            }
        }
    }
    var loadNearbyBusStopsCompletionBlocks : [CompletionBlock?] = []
}

// MARK: Private

fileprivate extension TFLRootViewController {
    func hideSplashscreenIfNeedBe() {
        guard let _ = splashScreenContainerView.superview else {
            return
        }
        UIView.animate(withDuration: 0.5, delay: 1.0, options: UIView.AnimationOptions.curveLinear, animations: {
            self.splashScreenContainerView.alpha = 0
        }) { _ in
            self.removeController(self.splashScreenController)
            self.splashScreenContainerView.removeFromSuperview()
            self.splashScreenController = nil
        }
    }
    
    
    func showOfflineView(_ show : Bool = true) {
        self.containerViewBottomConstraint.constant = show ? self.offlineView.frame.size.height : 0
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    func updateContentViewController(with arrivalsInfo: [TFLBusStopArrivalsInfo], and  coordinate: CLLocationCoordinate2D) {
        let radius = self.defaultRadius

        let oldTuples = self.nearbyBusStationController?.arrivalsInfo ?? []
        var mergedInfo : [TFLBusStopArrivalsInfo] = []
    
        switch (oldTuples.isEmpty,arrivalsInfo.isEmpty) {
        case (false,false):
            mergedInfo = oldTuples.mergedArrivalsInfo(arrivalsInfo)
        case (true,false):
            mergedInfo = arrivalsInfo
        case (_,true):
            let newTuples = oldTuples.map { $0.arrivalInfo(with:  coordinate.location) }
            mergedInfo = newTuples
        }
        
        let filteredArrivalsInfo = mergedInfo.filter { !$0.liveArrivals().isEmpty }.filter { $0.busStopDistance <= radius }
        self.nearbyBusStationController?.arrivalsInfo = filteredArrivalsInfo
        self.nearbyBusStationController?.currentUserCoordinate = coordinate
        self.mapViewController?.busStopPredicationCoordinateTuple = (filteredArrivalsInfo,coordinate)
       
    }
    
    @MainActor
    func loadNearbyBusstops() async {
        
        guard state.isComplete else {
            return
        }
        self.updateStatusView.state = .updating
        self.state = .determineCurrentLocation
        
        let coords = await TFLLocationManager.sharedManager.updateLocation()
        guard coords.isValid else {
            self.state = TFLLocationManager.sharedManager.enabled ? .errorCouldntDetermineCurrentLocation : .errorNoGPSAvailable
            self.updateStatusView.state = .updatePending
            return
        }
        
        await updateUI(with: coords)
        self.state = .noError
        self.updateStatusView.state = .updatePending
    }
    
    
    func updateUI(with coord : CLLocationCoordinate2D) async  {
        
        let stops = await retrieveBusstops(for: coord)
        self.updateContentViewController(with: stops, and: coord)
    }
    
    func retrieveBusstops(for location:CLLocationCoordinate2D) async -> [TFLBusStopArrivalsInfo] {
        self.state = .retrievingNearbyStations
        if location.isValid {
            
            self.state = .loadingArrivals
            self.updateNearbyBusStops(for: location)
            let stops = await self.busInfoAggregator.loadArrivalTimesForStoreStopPoints(with: location,with: self.defaultRadius)
            return stops
        }
        else
        {
            self.state = .errorNoGPSAvailable
            return []
        }
    }

    func updateNearbyBusStops(for currentLocation:CLLocationCoordinate2D )  {
        Task.detached(priority: .background) {
            _ = await self.tflClient.nearbyBusStops(with: currentLocation,radius: Int(self.defaultRadius))
        }
    }
}
//
// MARK: - TFLErrorContainerViewDelegate
//
extension TFLRootViewController : TFLErrorContainerViewDelegate {
    func errorContainerViewDidTapNoGPSEnabledButton(_ containerView: UIView, button: UIButton) {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        UIApplication.shared.open(url)
    }
    
    func errorContainerViewDidTapNoStationsButton(_ containerView: UIView, button: UIButton) {
        Task.detached {
            await self.loadNearbyBusstops()
        }
    }
}
//
// MARK: - TFLLocationManagerDelegate
//
extension TFLRootViewController : TFLLocationManagerDelegate {
    func locationManager(_ locationManager : TFLLocationManager, didChangeEnabledStatus enabled : Bool) {
        guard enabled else {
            return
        }
        Task.detached {
            await self.loadNearbyBusstops()
        }
    }
}
//
// MARK: - TFLNearbyBusStationsControllerDelegate
//
extension TFLRootViewController : TFLNearbyBusStationsControllerDelegate  {
    func nearbyBusStationsController(_ controller: TFLNearbyBusStationsController, didSelectBusstopWith identifier: String) {
       self.mapViewController?.showBusStop(with: identifier, animated: true)
    }
    
    func lastRefresh(of controller: TFLNearbyBusStationsController) -> Date? {
        return busInfoAggregator.lastUpdate
    }
    
    func refresh(controller: TFLNearbyBusStationsController, using completionBlock:@escaping ()->()) {
        Task {
            await self.loadNearbyBusstops()
            completionBlock()
        }
    }
}
//
// MARK: - TFLUpdateStatusViewDelegate
//
extension TFLRootViewController : TFLUpdateStatusViewDelegate {
    func didExpireTimerInStatusView(_ tflStatusView : TFLUpdateStatusView) {
        TFLLogger.shared.event(osLog: TFLRootViewController.loggingHandle, name: "refreshTimer")
        Task.detached {
            await self.loadNearbyBusstops()
        }
    }
}
