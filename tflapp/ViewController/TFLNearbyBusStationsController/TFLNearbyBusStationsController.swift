import UIKit
import MapKit
import CoreSpotlight
import os.signpost

protocol TFLNearbyBusStationsControllerDelegate : class {
    func refresh(controller: TFLNearbyBusStationsController, using completionBlock:@escaping ()->())
    func lastRefresh(of controller : TFLNearbyBusStationsController) -> Date?
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

extension NSNotification.Name {
    static let spotLightLineLookupNotification = NSNotification.Name("spotLightLineLookupNotification")
    
}

class TFLNearbyBusStationsController : UIViewController {
    enum SegueIdentifier : String {
        case stationDetailSegue =  "TFLStationDetailSegue"
    }
    let client = TFLClient()
    static let defaultTableViewRowHeight = CGFloat (120)
    
    fileprivate static let loggingHandle  = OSLog(subsystem: TFLLogger.subsystem, category: TFLLogger.category.refresh.rawValue)

    weak var delegate : TFLNearbyBusStationsControllerDelegate?
    
    @IBOutlet weak var ackLabel : UILabel! = nil {
        didSet {
            self.ackLabel.font = UIFont.tflFontPoweredBy()
            self.ackLabel.text = NSLocalizedString("TFLRootViewController.ackTitle", comment: "")
            self.ackLabel.textColor = .black
            self.ackLabel.isHidden = true
        }
    }
    
    @IBOutlet weak var lastUpdatedLabel : UILabel! = nil {
        didSet {
            self.lastUpdatedLabel.font = UIFont.tflRefreshTitle()
            self.lastUpdatedLabel.textColor = .black
            self.lastUpdatedLabel.isHidden = true
        }
    }
    
    var busStopArrivalViewModels :  [TFLBusStopArrivalsViewModel] = []
    
    @IBOutlet weak var tableView : UITableView!
    
    fileprivate let synchroniser = TFLSynchroniser(tag:"com.samedialabs.queue.tableview")
    var currentUserCoordinate = kCLLocationCoordinate2DInvalid
    var busStopPredicationTuple :  [TFLBusStopArrivalsInfo] = [] {
        didSet {
            synchroniser.synchronise { synchroniseEnd in
                let models = self.busStopPredicationTuple.sortedByBusStopDistance().map { TFLBusStopArrivalsViewModel(with: $0) }
                TFLLogger.shared.signPostStart(osLog: TFLNearbyBusStationsController.loggingHandle, name: "Collectiontransform")
                let (inserted ,deleted ,updated, moved) = self.busStopArrivalViewModels.transformTo(newList: models, sortedBy : TFLBusStopArrivalsViewModel.compare)
                TFLLogger.shared.signPostEnd(osLog: TFLNearbyBusStationsController.loggingHandle, name: "Collectiontransform")
                DispatchQueue.main.async {
                    self.tableView.performBatchUpdates({
                        self.busStopArrivalViewModels = models
                        let deletedIndexPaths = deleted.map { $0.index }.indexPaths().sorted(by:>)
                        self.tableView.deleteRows(at: deletedIndexPaths , with: .automatic)
                        let insertedIndexPaths = inserted.map { $0.index }.indexPaths().sorted(by:<)
                        self.tableView.insertRows(at: insertedIndexPaths , with: .automatic)
                        moved.forEach { self.tableView.moveRow(at: IndexPath(row: $0.oldIndex,section:0), to:  IndexPath(row: $0.newIndex,section:0)) }
                    }, completion: {  _ in
                        let updatedIndexPaths = updated.map { $0.index}.indexPaths()
                        let movedIndexPaths = moved.map { $0.newIndex }.indexPaths()
                        (updatedIndexPaths+movedIndexPaths).forEach { [weak self] indexPath in
                            if let cell = self?.tableView.cellForRow(at: indexPath) as? TFLBusStationArrivalsCell {
                                self?.configure(cell, at: indexPath)
                            }
                        }
                        synchroniseEnd()
                    })
                }
            }
        }
    }

    var contentOffsetObserver : NSKeyValueObservation?
    var updateTimeStamp = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addRefreshControl()
        updateLastUpdateTimeStamp()
        addContentOffsetObserver()
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = TFLNearbyBusStationsController.defaultTableViewRowHeight
        NotificationCenter.default.addObserver(self, selector: #selector(self.spotlightLookupNotificationHandler(_:)), name: NSNotification.Name.spotLightLineLookupNotification, object: nil)
        
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier, let segueIdentifier = TFLNearbyBusStationsController.SegueIdentifier(rawValue:identifier) else {
            return
        }
        switch segueIdentifier {
        case .stationDetailSegue:
            if let controller = segue.destination as? TFLStationDetailController, let (line,vehicleID,station) = sender as? (String,String?,String?) {
                controller.currentUserCoordinate   = currentUserCoordinate
                controller.lineInfo = (line.uppercased(),vehicleID,station)
            }
        }
    }

    @objc func refreshHandler(control : UIRefreshControl) {
        control.beginRefreshing()
        TFLLogger.shared.signPostStart(osLog: TFLNearbyBusStationsController.loggingHandle, name: "refreshHandler")
        self.delegate?.refresh(controller: self) { [weak self] in
            TFLLogger.shared.signPostEnd(osLog: TFLNearbyBusStationsController.loggingHandle, name: "refreshHandler")
            control.endRefreshing()
            self?.updateLastUpdateTimeStamp()
        }
    }
}

extension TFLNearbyBusStationsController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.busStopArrivalViewModels.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing:TFLBusStationArrivalsCell.self), for: indexPath)
        
        if let arrivalsCell = cell as? TFLBusStationArrivalsCell {
            configure(arrivalsCell, at: indexPath)
            arrivalsCell.delegate = self
        }
        return cell
    }
    
    @objc
    func spotlightLookupNotificationHandler(_ notification : Notification) {
        guard let line = notification.userInfo?[CSSearchableItemActivityIdentifier] as? String else {
            return
        }
        self.navigationController?.popToRootViewController(animated: false)
        self.updateAndShowLineInfo(line: line,with: nil,at:nil)
    }
    
}

extension TFLNearbyBusStationsController : TFLBusStationArrivalCellDelegate {
    
    func busStationArrivalCell(_ busStationArrivalCell: TFLBusStationArrivalsCell,didSelectLine line: String,with vehicleID: String,at station : String) {
        updateAndShowLineInfo(line: line,with: vehicleID,at: station)
    }
}

// MARK: Private

fileprivate extension TFLNearbyBusStationsController {
   
    func updateAndShowLineInfo(line : String,with vehicleID: String?,at station : String?) {
        updateLineInfoIfNeedbe(line) { [weak self] in
            self?.performSegue(withIdentifier: SegueIdentifier.stationDetailSegue.rawValue, sender: (line,vehicleID,station))
        }
    }
    
    
    func configure(_ cell : TFLBusStationArrivalsCell,at indexPath : IndexPath) {
        cell.configure(with: busStopArrivalViewModels[indexPath])
    }
    
    func addRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(self.refreshHandler(control:)), for: .valueChanged)
        self.tableView.refreshControl = refreshControl
        self.tableView.refreshControl?.transform = CGAffineTransform(scaleX: 0.75, y: 0.75)
    }
    
    
    func updateLastUpdateTimeStamp() {
        let date = self.delegate?.lastRefresh(of: self)
        self.lastUpdatedLabel.text = nil
        if  let dateString = date?.relativePastDateStringFromNow() {
            self.lastUpdatedLabel.text = NSLocalizedString("TFLNearbyBusStationsController.last_updated", comment: "") + dateString
        }
    }
    
    func hideBackgroundLabels(_ hide : Bool = true)  {
        self.ackLabel.isHidden = hide
        self.lastUpdatedLabel.isHidden = hide
    }
    
    func addContentOffsetObserver() {
        contentOffsetObserver = self.tableView.observe(\UITableView.contentOffset) { [weak self] _,_  in
            guard let offset = self?.tableView.contentOffset.y, (offset < 0) else {
                self?.updateTimeStamp = true
                self?.lastUpdatedLabel.isHidden = true
                self?.hideBackgroundLabels()
                return
            }
            self?.hideBackgroundLabels(false)
            if self?.updateTimeStamp == true {
                self?.updateTimeStamp = false
                self?.updateLastUpdateTimeStamp()
            }
        }
    }
    
    func updateLineInfoIfNeedbe(_ line : String,using completionblock: (() -> Void)? = nil) {
       
        if let lineInfo = TFLCDLineInfo.lineInfo(with: line, and: TFLBusStopStack.sharedDataStack.mainQueueManagedObjectContext) {
            completionblock?()
            if lineInfo.needsUpdate {
                self.client.lineStationInfo(for: line,
                                            context:TFLBusStopStack.sharedDataStack.privateQueueManagedObjectContext,
                                            with:.main) { [weak self] lineInfo,_ in
                                              self?.updateSpotlightWithLineInfo(lineInfo)
                                                
                }
            }
        } else {
            TFLHUD.show()
            client.lineStationInfo(for: line,
                                   context:TFLBusStopStack.sharedDataStack.privateQueueManagedObjectContext,
                                   with:.main) { [weak self] lineInfo,_ in
                                    TFLHUD.hide()
                                    completionblock?()
                                    self?.updateSpotlightWithLineInfo(lineInfo)
            }
        }
    }
    
    func updateSpotlightWithLineInfo(_ lineInfo : TFLCDLineInfo?) {
        lineInfo?.managedObjectContext?.perform {
            if let identifier = lineInfo?.identifier,
                let routes : [String] =  lineInfo?.routes?.compactMap ({ ($0 as? TFLCDLineRoute)?.name  }) {
                let dict = [ identifier : routes]
                let lineRouteList = TFLLineInfoRouteDirectory(with: dict)
                let provider = TFLCoreSpotLightDataProvider(with: lineRouteList)
                provider.searchableItems { items in
                    CSSearchableIndex.default().indexSearchableItems(items) { error in
                        if let _ = error {
                            return
                        }
                    }
                }
            }
        }
    }
    
}
