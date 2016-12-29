import UIKit
import MapKit
import Crashlytics
protocol TFLNearbyBusStationsControllerDelegate : class {
    func refresh(controller: TFLNearbyBusStationsController, using completionBlock:@escaping ()->())
}

class TFLNearbyBusStationsController : UITableViewController,TFLChangeSetProtocol {
    
    static let defaultTableViewRowHeight = CGFloat (120)

    private var foregroundNotificationHandler  : TFLNotificationObserver?

    
    weak var delegate : TFLNearbyBusStationsControllerDelegate?
    
    var sortedBusStopPredicationTuple :  [TFLBusStopArrivalsInfo] = [] {
        
        didSet (oldModel) {
            if oldModel.isEmpty {
                self.tableView.reloadData()
            }
            else
            {
                Crashlytics.log("oldTuples:\(oldModel.map { $0.debugInfo }.joined(separator: ","))\nnewTuples:\(sortedBusStopPredicationTuple.map { $0.debugInfo }.joined(separator: ","))")
                self.tableView.transition(from: oldModel, to: sortedBusStopPredicationTuple, with: TFLBusStopArrivalsInfo.compare) { updatedIndexPaths in
                    updatedIndexPaths.forEach { [weak self] indexPath in
                        if let cell = self?.tableView.cellForRow(at: indexPath) as? TFLBusStationArrivalsCell {
                            self?.configure(cell, at: indexPath)
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
        self.refreshControl?.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
        
        self.foregroundNotificationHandler = TFLNotificationObserver(notification: NSNotification.Name.UIApplicationWillEnterForeground.rawValue) { [weak self]  notification in
            self?.busStopPredicationTuple = self?.busStopPredicationTuple ?? []
        }
        
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = TFLNearbyBusStationsController.defaultTableViewRowHeight
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
        let viewModel = TFLBusStopArrivalsViewModel(with: model)
        cell.configure(with: viewModel)
    }
}


