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
            switch self.state {
            case State.errorNoGPSAvailable:
                Crashlytics.notify()
                self.contentView.isHidden = true
                self.ackLabel.isHidden = true
                showNoGPSEnabledError()
            case State.errorNoStationsNearby(let coord):
                Crashlytics.log("no stations for coordinate (lat,long):(\(coord.latitude),\(coord.longitude))")
                self.contentView.isHidden = true
                self.ackLabel.isHidden = true
                showNoStationsFoundError()
            case State.determineCurrentLocation:
                self.contentView.isHidden = self.nearbyBusStationController?.busStopPredicationTuple.isEmpty ?? true
                self.ackLabel.isHidden = self.nearbyBusStationController?.busStopPredicationTuple.isEmpty ?? true
                showLoadingCurrentLocationIfNeedBe()
            case State.retrievingNearbyStations:
                self.contentView.isHidden = false
                self.ackLabel.isHidden = self.nearbyBusStationController?.busStopPredicationTuple.isEmpty ?? true
                showLoadingNearbyStationsIfNeedBe()
            case State.loadingArrivals:
                self.contentView.isHidden = false
                self.ackLabel.isHidden = self.nearbyBusStationController?.busStopPredicationTuple.isEmpty ?? true
                showLoadingArrivalTimesIfNeedBe()
            case State.noError:
                hideInfoViews()
                self.ackLabel.isHidden = false
                self.contentView.isHidden = false
            }
        }
    }
    private enum SegueIdentifier : String {
        case nearbyBusStationController = "TFLNearbyBusStationsControllerSegue"
    }

    fileprivate var nearbyBusStationController : TFLNearbyBusStationsController?
    fileprivate let tflClient = TFLClient()
    private var foregroundNotificationHandler  : TFLNotificationObserver?
    @IBOutlet weak var ackLabel : UILabel!
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
        self.ackLabel.font = UIFont.tflFont(size: 14)
        self.ackLabel.text = NSLocalizedString("TFLRootViewController.ackTitle", comment: "")
        self.ackLabel.textColor = .black
        self.navigationController?.navigationBar.isHidden = true
        self.foregroundNotificationHandler = TFLNotificationObserver(notification: NSNotification.Name.UIApplicationWillEnterForeground.rawValue) { [weak self]  notification in
            self?.loadNearbyBusstops()
        }
        self.loadNearbyBusstops()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier , let segueIdentifier = SegueIdentifier(rawValue: identifier) else {
            return
        }
        switch segueIdentifier {
        case .nearbyBusStationController:
            if let nearbyBusStationController = segue.destination as? TFLNearbyBusStationsController {
                self.nearbyBusStationController = nearbyBusStationController
                self.nearbyBusStationController?.delegate = self
            }
        }
    }

}


// MARK: Private

fileprivate extension TFLRootViewController {
    
    func loadNearbyBusstops(using completionBlock:(()->())? = nil) {
        Crashlytics.notify()
        retrieveBusstopsForCurrentLocation { busStopPredictionTuples in
            self.nearbyBusStationController?.busStopPredicationTuple = busStopPredictionTuples
            completionBlock?()
        }
    }
    
  
    func retrieveBusstopsForCurrentLocation(using completionBlock:@escaping ([TFLBusStopArrivalsInfo])->()) {
        self.state = .determineCurrentLocation
        TFLLocationManager.sharedManager.updateLocation { [weak self] coord in
            self?.state = .retrievingNearbyStations
            if CLLocationCoordinate2DIsValid(coord) {
                self?.updateNearbyBusStops(for: coord)
                self?.loadArrivalTimesForStoreStopPoints(with: coord, using: completionBlock)
            }
            else
            {
                self?.state = .errorNoGPSAvailable
                completionBlock([])
            }
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
        self.nearbyBusStops(with: coord).forEach { [weak self] stopPoint in
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
            self.state = sortedStopPoints.isEmpty ? .errorNoStationsNearby(coordinate: coord) : .noError
            completionBlock(sortedStopPoints)
            Crashlytics.notify()
        }
    }
    
    func nearbyBusStops(with coordinate: CLLocationCoordinate2D, with radiusInMeter: Double = 300) -> [TFLCDBusStop] {
        let context = TFLBusStopStack.sharedDataStack.mainQueueManagedObjectContext
        
        // London : long=-0.252395&lat=51.506788
        // Latitude 1 Degree : 111.111 KM = 1/100 Degree => 1.11111 KM => 1/200 Degree ≈ 550m
        // Longitude 1 Degree : cos(51.506788)*111.111 = 0.3235612467* 111.111 = 35.9512136821 => 1/70 Degree ≈ 500 m
        let latOffset : Double = 1/200
        let longOffset : Double = 1/70
        let latLowerLimit = coordinate.latitude-latOffset
        let latUpperLimit = coordinate.latitude+latOffset
        let longLowerLimit = coordinate.longitude-longOffset
        let longUpperLimit = coordinate.longitude+longOffset
        

        let fetchRequest = NSFetchRequest<TFLCDBusStop>(entityName: "TFLCDBusStop")
        let predicate = NSPredicate(format: "(long>=%f AND long<=%f) AND (lat>=%f AND lat <= %f) AND (status == YES)",longLowerLimit,longUpperLimit,latLowerLimit,latUpperLimit)
        fetchRequest.predicate = predicate
        fetchRequest.returnsObjectsAsFaults = true
        fetchRequest.shouldRefreshRefetchedObjects = true
        var busStops : [TFLCDBusStop] = []
        let currentLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        context.performAndWait {
            if let stops =  try? context.fetch(fetchRequest) {
                busStops = stops.filter { currentLocation.distance(from: CLLocation(latitude: $0.lat, longitude: $0.long) ) < radiusInMeter }
            }
        }
        return busStops
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

// MARK: DataBase Generation

fileprivate extension TFLRootViewController {
    
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
}

// MARK: TFLNearbyBusStationsControllerDelegate

extension TFLRootViewController : TFLNearbyBusStationsControllerDelegate {
    func refresh(controller: TFLNearbyBusStationsController, using completionBlock:@escaping ()->()) {
        Crashlytics.notify()
        loadNearbyBusstops (using: completionBlock)
    }
}




