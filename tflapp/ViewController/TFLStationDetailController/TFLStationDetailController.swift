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

class TFLStationDetailController: UIViewController {
    enum SegueIdentifier : String {
        case tableViewControllerSegue =  "TFLStationDetailTableViewControllerSegue"
        case mapViewControllerSegue = "TFLStationDetailMapViewControllerSegue"
    }
    @IBOutlet weak var stationDetailErrorView : TFLStationDetailErrorView! {
        didSet {
            stationDetailErrorView.isHidden = !self.mapViewModels.isEmpty 
        }
    }
    
    fileprivate let defaultRefreshInterval : Int = 30
    
    fileprivate lazy var containerView : UIView = {
       let view = UIView(frame: .zero)
        let width : CGFloat = 32
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = width / 2
        view.backgroundColor = UIColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
        view.addSubview(self.updateStatusView)
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: width),
            view.heightAnchor.constraint(equalToConstant: width),
            updateStatusView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            updateStatusView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        return view
    }()
    fileprivate lazy var updateStatusView : TFLUpdateStatusView =  {
        let view = TFLUpdateStatusView(style: .compact, refreshInterval: self.defaultRefreshInterval)
        view.delegate = self
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 40),
            view.heightAnchor.constraint(equalToConstant: 40),
           
            ])
        return view
    }()
    @IBOutlet weak var heightConstraint : NSLayoutConstraint!
    @IBOutlet weak var titleHeaderView : TFLStationDetailHeaderView!
    fileprivate let tflClient = TFLClient()
    fileprivate var mapViewController : TFLStationDetailMapViewController?
    fileprivate var tableViewController : TFLStationDetailTableViewController?
    var currentUserCoordinate = kCLLocationCoordinate2DInvalid
    lazy var backBarButtonItem : UIBarButtonItem = {
        let image = #imageLiteral(resourceName: "back")
        let button = UIButton(frame: CGRect(origin:.zero,size:image.size))
        button.addTarget(self, action: #selector(self.backBarButtonHandler), for: .touchUpInside)
        button.setImage(image, for: .normal)
        return UIBarButtonItem(customView: button)
    }()
    
    private var mapViewModels : [TFLStationDetailMapViewModel] = [] {
        didSet {
             self.mapViewController?.viewModels = mapViewModels
        }
    }
    private var tableViewviewModels : [TFLStationDetailTableViewModel] = [] {
        didSet {
            self.tableViewController?.viewModels = tableViewviewModels
        }
    }

    var lineInfo : (line:String?,vehicleID : String?,station:String?) = (nil,nil,nil) {
        didSet {
            guard let line = lineInfo.line else {
                return
            }
            let location = currentUserCoordinate.location
            let context = TFLBusStopStack.sharedDataStack.privateQueueManagedObjectContext
            context.perform {
                let lineInfo =  TFLCDLineInfo.lineInfo(with: line, and: context)
                let routes = lineInfo?.routes?.array as? [TFLCDLineRoute] ?? []
                let models : [TFLStationDetailTableViewModel] =  routes.compactMap { TFLStationDetailTableViewModel(with: $0,location:location) }
                let mapModels : [TFLStationDetailMapViewModel] = routes.compactMap { TFLStationDetailMapViewModel(with: $0) }
                OperationQueue.main.addOperation {
                    self.stationDetailErrorView?.isHidden = !models.isEmpty
                    self.tableViewviewModels = models
                    self.mapViewModels = mapModels
                }
            }
            if let vehicleID = lineInfo.vehicleID {
                updateStatusView.isHidden = false
                updateStatusView.state = .updating
                trackVehicle(with: vehicleID) { [updateStatusView] _ in
                    updateStatusView.state = .updatePending
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleHeaderView.title = lineInfo.line ?? ""
        self.navigationItem.titleView = self.titleHeaderView
        self.navigationItem.leftBarButtonItem = self.backBarButtonItem
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.containerView)
    }



    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier, let segueIdentifier = SegueIdentifier(rawValue: identifier) else {
            return
        }
        switch segueIdentifier {
        case .tableViewControllerSegue:
            tableViewController = segue.destination as? TFLStationDetailTableViewController
            tableViewController?.delegate = self
            _ = tableViewController?.view
            tableViewController?.viewModels = tableViewviewModels
        case .mapViewControllerSegue:
            mapViewController = segue.destination as? TFLStationDetailMapViewController
            _ = mapViewController?.view
            mapViewController?.viewModels = mapViewModels
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
   
}
/// MARK: Private
fileprivate extension TFLStationDetailController {
    @objc func backBarButtonHandler() {
        self.navigationController?.popViewController(animated: true)
    }
    
    func trackVehicle(with vehicleID : String,using completionBlock :((_ arrivalInfos : [TFLVehicleArrivalInfo]) -> Void)?) {
        self.tflClient.vehicleArrivalsInfo(with: vehicleID) { [weak self] arrivalInfos,_ in
            let sortedInfos = (arrivalInfos ?? []).sorted { $0.timeToStation < $1.timeToStation }
            guard let station = self?.lineInfo.station,
                    let index = sortedInfos.map ({ $0.busStopIdentifier }).index(of:station ) else {
                completionBlock?(sortedInfos )
                return
            }
            
            let sortedInfosRange = Array(sortedInfos[0...index])
            for info in sortedInfosRange {
                print(info.description)
            }
            completionBlock?(sortedInfosRange )
        }
    }
}

extension TFLStationDetailController : TFLStationDetailTableViewControllerDelegate {
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

extension TFLStationDetailController : TFLUpdateStatusViewDelegate {
    func didExpireTimerInStatusView(_ tflStatusView : TFLUpdateStatusView) {
        guard let vehicleID = lineInfo.vehicleID else {
            return
            
        }
        trackVehicle(with: vehicleID) { [weak self] _ in
            self?.updateStatusView.state = .updatePending
        }
        
    }
}
