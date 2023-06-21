//
//  TFLStationDetailController.swift
//  tflapp
//
//  Created by Frank Saar on 29/05/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//

import UIKit
import MapKit
import Foundation
import CoreData
import Network

class TFLStationDetailController: UIViewController {
    enum SegueIdentifier : String {
        case tableViewControllerSegue =  "TFLStationDetailTableViewControllerSegue"
        case mapViewControllerSegue = "TFLStationDetailMapViewControllerSegue"
    }
    @IBOutlet weak var offlineView : UIView!
    @IBOutlet weak var tableViewContainerViewBottomConstraint : NSLayoutConstraint!
    @IBOutlet weak var stationDetailErrorView : TFLStationDetailErrorView! {
        didSet {
            stationDetailErrorView.isHidden = !self.mapViewModels.isEmpty 
        }
    }
    fileprivate lazy var networkMonitor : NWPathMonitor = {
        let monitor = NWPathMonitor()
        monitor.pathUpdateHandler = { [weak self] path in
            let isOffline = path.status != .satisfied
            self?.showOfflineView(isOffline)
        }
        return monitor
    }()
    fileprivate let defaultRefreshInterval : Int = 30
    
    fileprivate lazy var containerView : UIView = {
        let view = UIView()
        let width : CGFloat = 32
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        view.layer.cornerRadius = width / 2
        view.addSubview(self.updateStatusView)
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: width),
            view.heightAnchor.constraint(equalToConstant: width),
            updateStatusView.centerXAnchor.constraint(equalTo: view.centerXAnchor,constant: 1),
            updateStatusView.centerYAnchor.constraint(equalTo: view.centerYAnchor,constant: 0.5)
            ])
        return view
    }()
    fileprivate lazy var updateStatusView : TFLUpdateStatusView =  {
        let view = TFLUpdateStatusView(style: .compact, refreshInterval: self.defaultRefreshInterval)
        view.delegate = self
        view.state = .paused
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 40),
            view.heightAnchor.constraint(equalToConstant: 40),
           
            ])
        return view
    }()
    @IBOutlet weak var tableContainerView : UIView!
    @IBOutlet weak var mapContainerView : UIView!
    @IBOutlet weak var heightConstraint : NSLayoutConstraint!
    @IBOutlet weak var titleHeaderView : TFLStationDetailHeaderView!
    fileprivate let tflClient = TFLClient()
    fileprivate var mapViewController : TFLStationDetailMapViewController?
    fileprivate var tableViewController : TFLStationDetailTableViewController?
    var currentUserCoordinate = kCLLocationCoordinate2DInvalid
    lazy var backBarButtonItem : UIBarButtonItem = UIBarButtonItem(customView: self.backButton)
    
    lazy var backButton : UIButton = {
        let config = UIImage.SymbolConfiguration(pointSize: 30,weight:.light,scale:.medium)
        let image = UIImage(systemName: "chevron.left",withConfiguration:config)
        let button = UIButton(frame: CGRect(origin:.zero,size:image?.size ?? .zero))
            button.addTarget(self, action: #selector(self.backBarButtonHandler), for: .touchUpInside)
            button.setImage(image, for: .normal)
        button.accessibilityLabel = NSLocalizedString("TFLStationDetailController.backbutton.accessibitliyTitle",comment:"")
            return button
        }()
    
    private var mapViewModels : [TFLStationDetailMapViewModel] = []
    private var tableViewviewModels : [TFLStationDetailTableViewModel] = []

    var lineInfo : (line:String?,vehicleID : String?,station:String?,arrivalInfos :[TFLVehicleArrivalInfo]?) = (nil,nil,nil,nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        mapViewController?.delegate = tableViewController
        self.networkMonitor.start(queue: .main)
        self.titleHeaderView.title = lineInfo.line ?? ""
        self.navigationItem.titleView = self.titleHeaderView
        self.navigationItem.leftBarButtonItem = self.backBarButtonItem
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.containerView)
        
        setup()
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier, let segueIdentifier = SegueIdentifier(rawValue: identifier) else {
            return
        }
        switch segueIdentifier {
        case .tableViewControllerSegue:
            tableViewController = segue.destination as? TFLStationDetailTableViewController
            tableViewController?.delegate = self
        case .mapViewControllerSegue:
            mapViewController = segue.destination as? TFLStationDetailMapViewController
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//        guard traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle else {
//            return
//        }
//        updateColors()
//    }
}

//
// MARK: - Private
//
fileprivate extension TFLStationDetailController {
    func updateColors() {
        self.backButton.tintColor = UIColor(named:"tflStationDetailControllerBackButtonColor")
        self.containerView.backgroundColor = UIColor(named:"tflNavigationItemBackgroundColor")
        self.view.backgroundColor = UIColor(named: "tflBackgroundColor")
        self.mapContainerView.backgroundColor =  UIColor(named: "tflBackgroundColor")
        self.tableContainerView.backgroundColor = UIColor(named: "tflBackgroundColor")
        self.stationDetailErrorView.backgroundColor = UIColor(named: "tflBackgroundColor")
    }
    
    func showOfflineView(_ show : Bool = true) {
        self.tableViewContainerViewBottomConstraint.constant = show ? self.offlineView.frame.size.height : 0
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func backBarButtonHandler() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func setup() {
        let arrivalInfos = lineInfo.arrivalInfos ?? []
        self.tableViewController?.station = lineInfo.station

        guard let line = lineInfo.line else {
            return
        }
        
        controllerModels(for:line) { [weak self] models,mapModels in
            self?.stationDetailErrorView?.isHidden = !models.isEmpty
            let normalizedInfos = self?.normalizeArrivalsInfo(arrivalInfos,station:self?.lineInfo.station ?? "",tableViewModels:models)
            
            self?.tableViewController?.updateData(with: models,newArrivalInfos: normalizedInfos,for:line)
            self?.mapViewController?.viewModels = mapModels
            
            self?.tableViewviewModels = models
            self?.mapViewModels = mapModels
            
            if let _ = self?.lineInfo.vehicleID {
                self?.containerView.isHidden = false
                self?.updateStatusView.state = .updatePending
            }
        }
        updateColors()
    }
    
    func controllerModels(for line : String,on queue : OperationQueue = .main,using completionBlock : @escaping (_ tableViewModels:[TFLStationDetailTableViewModel],_ mapViewModels: [TFLStationDetailMapViewModel]) -> Void) {

        let location = self.currentUserCoordinate.location
        let context = TFLBusStopStack.sharedDataStack.privateQueueManagedObjectContext
        context.perform {
            let lineInfo =  TFLCDLineInfo.lineInfo(with: line, and: context)
            let routes = lineInfo?.routes?.array as? [TFLCDLineRoute] ?? []
            let models : [TFLStationDetailTableViewModel] =  routes.compactMap{ TFLStationDetailTableViewModel(with: $0,location:location) }
            let mapModels : [TFLStationDetailMapViewModel] = routes.compactMap{ TFLStationDetailMapViewModel(with: $0) }
            queue.addOperation{
                completionBlock(models,mapModels)
            }
        }
    }
    
    
    func trackVehicle(with vehicleID : String,on queue : OperationQueue = .main,using completionBlock :((_ arrivalInfos : [TFLVehicleArrivalInfo]) -> Void)?) {
        guard let station = self.lineInfo.station  else {
            completionBlock?([])
            return
        }
       
        self.tflClient.vehicleArrivalsInfo(with: vehicleID) { [weak self] arrivalInfos,_ in
            guard let self = self else {
                completionBlock?([])
                return
            }
            let normalizedInfos = self.normalizeArrivalsInfo(arrivalInfos,station:station,tableViewModels:self.tableViewviewModels)
            queue.addOperation{
                completionBlock?(normalizedInfos )
            }
        }
    }
    
    func normalizeArrivalsInfo(_ arrivalInfos : [TFLVehicleArrivalInfo]?,station : String, tableViewModels : [TFLStationDetailTableViewModel]) -> [TFLVehicleArrivalInfo] {
        guard let arrivalInfos = arrivalInfos else {
            return []
        }
        let naptanRoute = naptanIdListWithStation(station, from: tableViewModels)
        guard !naptanRoute.isEmpty || station.isEmpty else {
            return []
        }
        let sortedInfos = arrivalInfos.sorted{ info1,info2 in
            let idx1 = naptanRoute.firstIndex(of:info1.busStopIdentifier) ?? 0
            let idx2 = naptanRoute.firstIndex(of:info2.busStopIdentifier) ?? 0
            return idx1 < idx2
        }
        
        guard let index = sortedInfos.map({ $0.busStopIdentifier }).firstIndex(of:station ) else {
            return []
        }
        let sortedInfosRange = Array(sortedInfos[0...index])
        return sortedInfosRange
    }
    
    func naptanIdListWithStation(_ station : String,from tableViewModels : [TFLStationDetailTableViewModel]) -> [String] {
        let naptanIDLists = tableViewModels.naptanIDLists
        let naptanIdList = naptanIDLists.first { lists in
            guard let _ = lists.firstIndex(of:station) else {
                return false
            }
            return true
        } ?? []
        return naptanIdList
    }
    
    func updateTableViewController(with vehicleID : String) {
        updateStatusView.state = .updating
        trackVehicle(with: vehicleID) { [weak self] arrivalInfos in
            self?.containerView.isHidden = arrivalInfos.isEmpty
            self?.updateStatusView.state = .updatePending
            self?.tableViewController?.updateData(newArrivalInfos: arrivalInfos)
        }
    }
}

// MARK: - TFLStationDetailTableViewControllerDelegate

extension TFLStationDetailController : TFLStationDetailTableViewControllerDelegate {
    func tflStationDetailTableViewController(_ controller: TFLStationDetailTableViewController, didSelectBusstopWith identifier: String) {
        self.mapViewController?.showBusStop(with: identifier, animated: true)
    }
    
    func tflStationDetailTableViewController(_ controller: TFLStationDetailTableViewController, didShowSection section: Int) {
        self.mapViewController?.showRouteForModel(at: section, animated: true)
    }
    
    func tflStationDetailTableViewController(_ controller: TFLStationDetailTableViewController,with header: UITableViewHeaderFooterView, didPanBy distance: CGFloat) {
        let newHeightOffset = self.heightConstraint.constant + distance
        let maxHeightOffset = self.view.frame.size.height - header.frame.size.height
        self.heightConstraint.constant = min(newHeightOffset,maxHeightOffset)
        self.view.layoutIfNeeded()
    }
}

// MARK: - TFLUpdateStatusViewDelegate

extension TFLStationDetailController : TFLUpdateStatusViewDelegate {
    func didExpireTimerInStatusView(_ tflStatusView : TFLUpdateStatusView) {
        guard let vehicleID = lineInfo.vehicleID else {
            return
            
        }
        updateTableViewController(with: vehicleID)
    }
}
