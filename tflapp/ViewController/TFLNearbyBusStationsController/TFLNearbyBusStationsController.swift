import UIKit
import MapKit
import os.signpost

protocol TFLNearbyBusStationsControllerDelegate : class {
    func refresh(controller: TFLNearbyBusStationsController, using completionBlock:@escaping ()->())
}

extension MutableCollection where Index == Int, Iterator.Element == TFLBusStopArrivalsViewModel {
    subscript(indexPath : IndexPath) -> TFLBusStopArrivalsViewModel {
        get {
            return self[indexPath.row]
        }
        set {
            self[indexPath.row] = newValue
        }
    }
}

class TFLNearbyBusStationsController : UITableViewController {
    enum SegueIdentifier : String {
        case stationDetailSegue =  "TFLStationDetailSegue"
    }
    static let defaultTableViewRowHeight = CGFloat (120)

    private var foregroundNotificationHandler  : TFLNotificationObserver?
    fileprivate static let loggingHandle  = OSLog(subsystem: TFLLogger.subsystem, category: TFLLogger.category.refresh.rawValue)

    weak var delegate : TFLNearbyBusStationsControllerDelegate?
    var busStopArrivalViewModels :  [TFLBusStopArrivalsViewModel] = [] {

        didSet (oldModel) {
            self.tableView.transition(from: oldModel, to: busStopArrivalViewModels, with: TFLBusStopArrivalsViewModel.compare) { updatedIndexPaths in
                updatedIndexPaths.forEach { [weak self] indexPath in
                    if let cell = self?.tableView.cellForRow(at: indexPath) as? TFLBusStationArrivalsCell {
                        self?.configure(cell, at: indexPath)
                    }
                }
            }
        }
    }

    var busStopPredicationTuple :  [TFLBusStopArrivalsInfo] = [] {
        didSet {
            DispatchQueue.global().async {
                let models = self.busStopPredicationTuple.sorted { $0.busStopDistance < $1 .busStopDistance }.map { TFLBusStopArrivalsViewModel(with: $0) }
                DispatchQueue.main.async {
                    self.busStopArrivalViewModels = models
                }
            }
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.refreshHandler(control:)), for: .valueChanged)
        self.refreshControl = refreshControl
        self.refreshControl?.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)

        self.foregroundNotificationHandler = TFLNotificationObserver(notification: UIApplication.willEnterForegroundNotification) { [weak self]  _ in
            self?.busStopPredicationTuple = self?.busStopPredicationTuple ?? []
        }

        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = TFLNearbyBusStationsController.defaultTableViewRowHeight
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier, let segueIdentifier = TFLNearbyBusStationsController.SegueIdentifier(rawValue:identifier) else {
            return
        }
        switch segueIdentifier {
        case .stationDetailSegue:
            if let controller = segue.destination as? TFLStationDetailController, let line = sender as? String {
                controller.line = line
            }
        }
    }

    @objc func refreshHandler(control : UIRefreshControl) {
        control.beginRefreshing()
        TFLLogger.shared.signPostStart(osLog: TFLNearbyBusStationsController.loggingHandle, name: "refreshHandler")
        self.delegate?.refresh(controller: self) {
            TFLLogger.shared.signPostEnd(osLog: TFLNearbyBusStationsController.loggingHandle, name: "refreshHandler")
            control.endRefreshing()
        }

    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.busStopArrivalViewModels.count
    }


     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing:TFLBusStationArrivalsCell.self), for: indexPath)

        if let arrivalsCell = cell as? TFLBusStationArrivalsCell {
            configure(arrivalsCell, at: indexPath)
            arrivalsCell.delegate = self
        }
        return cell
     }
}

extension TFLNearbyBusStationsController : TFLBusStationArrivalCellDelegate {
    func busStationArrivalCell(_ busStationArrivalCell: TFLBusStationArrivalsCell,didSelectLine line: String) {
        self.performSegue(withIdentifier: SegueIdentifier.stationDetailSegue.rawValue, sender: line)
    }
}

// MARK: Private

fileprivate extension TFLNearbyBusStationsController {

    func configure(_ cell : TFLBusStationArrivalsCell,at indexPath : IndexPath) {
        cell.configure(with: busStopArrivalViewModels[indexPath])
    }
}
