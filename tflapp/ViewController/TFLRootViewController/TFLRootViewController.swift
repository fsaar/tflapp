import CoreLocation
import UIKit
import CoreData



class TFLRootViewController: UIViewController {
    fileprivate static let searchParameter  : (min:Double,initial:Double) = (100,350)
    fileprivate let networkBackgroundQueue = OperationQueue()
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
    fileprivate(set) var DefaultRefreshInterval : TimeInterval = 15

    fileprivate var state : State = .noError {
        didSet {
            let shouldHide = self.nearbyBusStationController?.busStopPredicationTuple.isEmpty ?? true

            switch self.state {
            case State.errorNoGPSAvailable:
                self.contentView.isHidden = true
                showNoGPSEnabledError()
            case State.errorNoStationsNearby:
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
        return TFLTimer(timerInterVal: DefaultRefreshInterval) { [weak self] _ in
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

        self.foregroundNotificationHandler = TFLNotificationObserver(notification: NSNotification.Name.UIApplicationWillEnterForeground.rawValue) { [weak self]  _ in
            self?.loadNearbyBusstops()
            self?.refreshTimer?.start()
        }
        self.backgroundNotificationHandler = TFLNotificationObserver(notification:NSNotification.Name.UIApplicationDidEnterBackground.rawValue) { [weak self]  _ in
            self?.refreshTimer?.stop()
        }
        TFLRequestManager.shared.delegate = self
        self.loadNearbyBusstops()
        self.refreshTimer?.start()
//        loadBusStops { [weak self] in
//            self?.loadLineStations()
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
    func mergeInfo(_ newInfo : [TFLBusStopArrivalsInfo],with oldInfo:[TFLBusStopArrivalsInfo] ) ->  [TFLBusStopArrivalsInfo] {
        let dict = Dictionary(uniqueKeysWithValues: oldInfo.map { ($0.identifier,$0)} )
        let mergedInfo : [TFLBusStopArrivalsInfo] = newInfo.map {  info in
            guard info.arrivals.isEmpty else {
                return info
            }
            return dict[info.identifier] ?? info
        }
        return mergedInfo
    }
    
    func updateContentViewController(with arrivalsInfo: [TFLBusStopArrivalsInfo], and coordinate: CLLocationCoordinate2D) {
        let oldTuples = self.nearbyBusStationController?.busStopPredicationTuple ?? []
        let mergedInfo = mergeInfo(arrivalsInfo, with: oldTuples)
        let filteredArrivalsInfo = mergedInfo.filter { !$0.arrivals.isEmpty }
        self.state = filteredArrivalsInfo.isEmpty ? .errorNoStationsNearby(coordinate: coordinate) : .noError
        self.nearbyBusStationController?.busStopPredicationTuple = filteredArrivalsInfo
        self.mapViewController?.busStopPredicationCoordinateTuple = (filteredArrivalsInfo,coordinate)
    }


    func loadNearbyBusstops(using completionBlock:(()->())? = nil) {
        self.state = .determineCurrentLocation
        TFLLocationManager.sharedManager.updateLocation { [weak self] coord in
            guard let state = self?.state,state.isComplete || state.isDeterminingCurrentLocation  else {
                return
            }
            self?.retrieveBusstops(for: coord) { busStopPredictionTuples in
                self?.updateContentViewController(with: busStopPredictionTuples, and: coord)
                completionBlock?()
            }

        }
    }


    func retrieveBusstops(for location:CLLocationCoordinate2D, using completionBlock:@escaping ([TFLBusStopArrivalsInfo])->()) {
        self.state = .retrievingNearbyStations
        if CLLocationCoordinate2DIsValid(location) {
            let userDefaultRadius = UserDefaults.standard.double(forKey: "Distance")
            let searchParam = TFLRootViewController.searchParameter
            let radius = userDefaultRadius < searchParam.min ? searchParam.initial : userDefaultRadius
            self.loadArrivalTimesForStoreStopPoints(with: location,with: radius, using: completionBlock)
            self.updateNearbyBusStops(for: location)
        }
        else
        {
            self.state = .errorNoGPSAvailable
            completionBlock([])
        }
    }

    func updateNearbyBusStops(for currentLocation:CLLocationCoordinate2D ) {
       self.tflClient.nearbyBusStops(with: currentLocation)
      
    }

    func loadArrivalTimesForStoreStopPoints(with coord: CLLocationCoordinate2D,
                                            with distance : Double = TFLRootViewController.searchParameter.initial,
                                            using completionBlock:@escaping ([TFLBusStopArrivalsInfo])->()) {
        self.state = .loadingArrivals
        let currentLocation = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        let group = DispatchGroup()
        var newStopPoints : [TFLBusStopArrivalsInfo] = []
        let context = TFLBusStopStack.sharedDataStack.privateQueueManagedObjectContext
        let queue = self.networkBackgroundQueue
        DispatchQueue.global().async {
            
            TFLBusStopStack.sharedDataStack.nearbyBusStops(with: coord,with: distance,and: context) { busStops in
                busStops.forEach { [weak self] stopPoint in
                    group.enter()
                    context.perform {
                        self?.tflClient.arrivalsForStopPoint(with: stopPoint.identifier,with: queue) { predictions,_ in
                            context.perform {
                                let distance = currentLocation.distance(from: CLLocation(latitude: stopPoint.coord.latitude, longitude: stopPoint.coord.longitude))
                                let tuple = TFLBusStopArrivalsInfo(busStop: stopPoint, busStopDistance: distance, arrivals: predictions ?? [])
                                newStopPoints += [tuple]
                                group.leave()
                            }
                        }
                    }
                }
                group.notify(queue: DispatchQueue.main) {
                    let sortedStopPoints = newStopPoints.sorted { $0.busStopDistance < $1.busStopDistance }
                    completionBlock(sortedStopPoints)
                }
            }
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
        guard let url = URL(string: UIApplicationOpenSettingsURLString) else {
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

// MARK: DataBase Generation

fileprivate extension TFLRootViewController {
    func loadLineStations() {
        self.linesFromBusStops { [weak self] lines in
            self?.load(lines: Array(lines), index: 0) {
                let context = TFLCoreDataStack.sharedDataStack.privateQueueManagedObjectContext
                context.performAndWait {
                    try? context.save()
                }
            }
        }
    }

    func linesFromBusStops(using completionBlock : ((_ lines : Set<String>) -> Void )?)  {
        var lines : Set<String> = []
        let context = TFLCoreDataStack.sharedDataStack.privateQueueManagedObjectContext
        let fetchRequest = NSFetchRequest<TFLCDBusStop>(entityName:String(describing: TFLCDBusStop.self))
        fetchRequest.includesSubentities = false
        fetchRequest.includesPropertyValues = false
        fetchRequest.propertiesToFetch = ["lines"]
        context.perform {
            if let stops = try? context.fetch(fetchRequest) as [TFLCDBusStop] {
                let lineList = stops.reduce([]) { sum,stop in
                    return sum + (stop.lines ?? [])
                }
                lines = Set(lineList)
                completionBlock?(lines)
            }
        }
    }
    func load(lines : [String],index : Int = 0,using completionBlock: (()->())? = nil) {
        guard index < lines.count else {
            completionBlock?()
            return
        }
        let line = lines[index]
        print("\(index). \(line)")
        self.tflClient.lineStationInfo(for: line) { [weak self] _,_ in
            self?.load(lines: lines, index: index+1,using:completionBlock)
        }
    }

// MARK: DataBase Generation (BusStops)

    func loadBusStops(of page: UInt = 0,using completionBlock: (()->())?) {
        self.tflClient.busStops(with: page) { [weak self] busStops,_ in
            guard let busStops = busStops, !busStops.isEmpty else {
                completionBlock?()
                return
            }
            print (page)
            self?.loadBusStops(of: page+1,using:completionBlock)
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
