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
    @IBOutlet weak var heightConstraint : NSLayoutConstraint!
    @IBOutlet weak var titleHeaderView : TFLStationDetailHeaderView!
    var mapViewController : TFLStationDetailMapViewController?
    var tableViewController : TFLStationDetailTableViewController?
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

    var lineInfo : (line:String?,towards:String?) = (nil,nil) {
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
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleHeaderView.title = lineInfo.line ?? ""
        self.navigationItem.titleView = self.titleHeaderView
        self.navigationItem.leftBarButtonItem = self.backBarButtonItem
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
