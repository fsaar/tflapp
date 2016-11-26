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
                self.transition(tableView: self.tableView, from: oldModel, to: sortedBusStopPredicationTuple)
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
    
    fileprivate func transition(tableView: UITableView,from oldArrivalInfo: [TFLBusStopArrivalsInfo],to newArrivalInfo: [TFLBusStopArrivalsInfo]) {
        let (inserted ,deleted ,updated, moved) = self.evaluateLists(oldList: oldArrivalInfo, newList: newArrivalInfo, compare : TFLBusStopArrivalsInfo.compare)
        
        tableView.beginUpdates()
        let insertedIndexPaths = inserted.map { IndexPath(row: $0.index,section:0)}
        tableView.insertRows(at: insertedIndexPaths , with: .left)
        let deledtedIndexPaths = deleted.map { IndexPath(row: $0.index,section:0)}
        tableView.deleteRows(at: deledtedIndexPaths , with: .right)
        tableView.endUpdates()
        
        if !updated.isEmpty {
            tableView.beginUpdates()
            let updatedIndexPaths = Set(updated.map { IndexPath(row: $0.index,section:0)})
            let visibleIndexPaths = Set(tableView.indexPathsForVisibleRows ?? [])
            let visibleReloadablePaths = visibleIndexPaths.intersection(updatedIndexPaths)
            visibleReloadablePaths.map  { (tableView.cellForRow(at: $0) ,$0) }.forEach { cell, indexPath in
                if let cell = cell as? TFLBusStationArrivalsCell {
                    configure(cell, at: indexPath)
                }
            }
            tableView.endUpdates()
        }
        
        if !moved.isEmpty {
            tableView.beginUpdates()
            moved.forEach { tableView.moveRow(at: IndexPath(row: $0.oldIndex,section:0), to:  IndexPath(row: $0.newIndex,section:0)) }
            tableView.endUpdates()
            
            tableView.beginUpdates()
            let indexPaths = moved.map { IndexPath(row: $0.newIndex,section:0)}
            let visibleIndexPaths = Set(tableView.indexPathsForVisibleRows ?? [])
            let visibleMovedPaths = visibleIndexPaths.intersection(indexPaths)
            visibleMovedPaths.map { (tableView.cellForRow(at: $0) ,$0) }.forEach { cell, indexPath in
                if let cell = cell as? TFLBusStationArrivalsCell {
                    configure(cell, at: indexPath)
                }
            }
            tableView.endUpdates()
        }

    }
}


