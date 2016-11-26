import UIKit
import MapKit

protocol TFLNearbyBusStationsControllerDelegate : class {
    func refresh(controller: TFLNearbyBusStationsController, using completionBlock:@escaping ()->())
}

class TFLNearbyBusStationsController : UITableViewController,TFLChangeSetProtocol {
    let defaultTableViewRowHeight = CGFloat (119)
    fileprivate let distanceFormatter : LengthFormatter = {
        let formatter = LengthFormatter()
        formatter.unitStyle = .short
        formatter.numberFormatter.roundingMode = .halfUp
        formatter.numberFormatter.maximumFractionDigits = 0
        return formatter
    }()
    
    fileprivate let timeFormatter : DateFormatter = { () -> (DateFormatter) in
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.calendar = Calendar(identifier: .iso8601)
        return formatter
    }()
    private var foregroundNotificationHandler  : TFLNotificationObserver?

    
    weak var delegate : TFLNearbyBusStationsControllerDelegate?
    
    var sortedBusStopPredicationTuple :  [TFLBusStopArrivalsInfo] = [] {
        
        didSet (oldModel) {
            if oldModel.isEmpty {
                self.tableView.reloadData()
            }
            else
            {
                self.tableView.transition(from: oldModel, to: sortedBusStopPredicationTuple, with: TFLBusStopArrivalsInfo.compare) { updatedIndexPaths in
                    let visibleIndexPaths = Set(tableView.indexPathsForVisibleRows ?? [])
                    let visibleUpdatablePaths = visibleIndexPaths.intersection(updatedIndexPaths)
                    visibleUpdatablePaths.map  { (tableView.visibleCells[$0.row],$0) }.forEach { cell, indexPath in
                        if let cell = cell as? TFLBusStationArrivalsCell {
                            configure(cell, at: indexPath)
                        }
                    }

                }
            }
        }
    }

    var busStopPredicationTuple :  [TFLBusStopArrivalsInfo] = [] {
        didSet {
            self.sortedBusStopPredicationTuple = self.busStopPredicationTuple.sorted { $0.busStopDistance < $1 .busStopDistance }
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
        return self.sortedBusStopPredicationTuple.count
    }
    
    
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing:TFLBusStationArrivalsCell.self), for: indexPath)
        
        if let arrivalsCell = cell as? TFLBusStationArrivalsCell {
            configure(arrivalsCell, at: indexPath)
        }
        return cell
     }
    
    
}

// MARK: Private

fileprivate extension TFLNearbyBusStationsController {
    fileprivate func configure(_ cell : TFLBusStationArrivalsCell,at indexPath : IndexPath) {
        let model = self.sortedBusStopPredicationTuple[indexPath.row]
        let viewModel = TFLBusStopArrivalsViewModel(with: model,  distanceFormatter: distanceFormatter, and: timeFormatter )
        cell.configure(with: viewModel)
    }
}


