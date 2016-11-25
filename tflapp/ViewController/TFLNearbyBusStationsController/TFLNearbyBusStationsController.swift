import UIKit
import MapKit

protocol TFLNearbyBusStationsControllerDelegate : class {
    func refresh(controller: TFLNearbyBusStationsController, using completionBlock:@escaping ()->())
}

class TFLNearbyBusStationsController : UITableViewController,TFLChangeSetProtocol {
    let defaultTableViewRowHeight = CGFloat (119)
    private let distanceFormatter : LengthFormatter = {
        let formatter = LengthFormatter()
        formatter.unitStyle = .short
        formatter.numberFormatter.roundingMode = .halfUp
        formatter.numberFormatter.maximumFractionDigits = 0
        return formatter
    }()
    
    private let timeFormatter : DateFormatter = { () -> (DateFormatter) in
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.calendar = Calendar(identifier: .iso8601)
        return formatter
    }()
    private var foregroundNotificationHandler  : TFLNotificationObserver?

    
    weak var delegate : TFLNearbyBusStationsControllerDelegate?
    
    fileprivate var busStopArrivalsViewModel : [TFLBusStopArrivalsViewModel] = [] {
        didSet (oldModel) {
            let (inserted ,deleted ,updated, moved) = self.evaluateLists(oldList: oldModel, newList: busStopArrivalsViewModel, compare : TFLBusStopArrivalsViewModel.compare)
            
            self.tableView.beginUpdates()
            let insertedIndexPaths = inserted.map { IndexPath(row: $0.index,section:0)}
            self.tableView.insertRows(at: insertedIndexPaths , with: .left)
            let deledtedIndexPaths = deleted.map { IndexPath(row: $0.index,section:0)}
            self.tableView.deleteRows(at: deledtedIndexPaths , with: .right)
            self.tableView.endUpdates()
            
            if !updated.isEmpty {
                self.tableView.beginUpdates()
                let updatedIndexPaths = Set(updated.map { IndexPath(row: $0.index,section:0)})
                let visibleIndexPaths = Set(self.tableView.indexPathsForVisibleRows ?? [])
                let visibleReloadablePaths = visibleIndexPaths.intersection(updatedIndexPaths)
                visibleReloadablePaths.map { (self.tableView.cellForRow(at: $0) ,self.busStopArrivalsViewModel[$0.row]) }.forEach { cell, model in
                    cell?.textLabel?.text = "\(model.identifier):\(model.distance)"
                }
                self.tableView.endUpdates()
            }
            
            if !moved.isEmpty {
                self.tableView.beginUpdates()
                moved.forEach { self.tableView.moveRow(at: IndexPath(row: $0.oldIndex,section:0), to:  IndexPath(row: $0.newIndex,section:0)) }
                self.tableView.endUpdates()
                
                self.tableView.beginUpdates()
                let indexPaths = moved.map { IndexPath(row: $0.newIndex,section:0)}
                let visibleIndexPaths = Set(self.tableView.indexPathsForVisibleRows ?? [])
                let visibleMovedPaths = visibleIndexPaths.intersection(indexPaths)
                visibleMovedPaths.map { (self.tableView.cellForRow(at: $0) ,self.busStopArrivalsViewModel[$0.row]) }.forEach { cell, model in
                    cell?.textLabel?.text = "\(model.identifier):\(model.distance)"
                }
                self.tableView.endUpdates()
            }
            
        }
    }
    var busStopPredicationTuple :  [TFLBusStopArrivalsInfo] = [] {
        didSet {
            self.busStopArrivalsViewModel = self.busStopPredicationTuple.sorted { $0.busStopDistance < $1 .busStopDistance }.map { TFLBusStopArrivalsViewModel(with: $0,  distanceFormatter: distanceFormatter, and: timeFormatter ) }
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.refreshHandler(control:)), for: .valueChanged)
        self.refreshControl = refreshControl
        
        self.foregroundNotificationHandler = TFLNotificationObserver(notification: NSNotification.Name.UIApplicationWillEnterForeground.rawValue) { [weak self]  notification in
            self?.busStopPredicationTuple = self?.busStopPredicationTuple ?? []
        }
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = defaultTableViewRowHeight
    }

    func refreshHandler(control : UIRefreshControl) {
        control.beginRefreshing()
        self.delegate?.refresh(controller: self) {
            control.endRefreshing()
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.busStopArrivalsViewModel.count
    }
    
    
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing:TFLBusStationArrivalsCell.self), for: indexPath)
        
        if let arrivalsCell = cell as? TFLBusStationArrivalsCell {
            let viewModel = busStopArrivalsViewModel[indexPath.row]
            arrivalsCell.configure(with: viewModel)
        }
        return cell
     }
    
    
}

// MARK: Private

private extension TFLNearbyBusStationsController {
    func validateArrivalTimes() {
        
    }
}


