//
//  TFLStationDetailController.swift
//  tflapp
//
//  Created by Frank Saar on 29/05/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//

import UIKit
import Foundation
import CoreData

class TFLStationDetailController: UIViewController {
    enum SegueIdentifier : String {
        case tableViewControllerSegue =  "TFLStationDetailTableViewControllerSegue"
        case mapViewControllerSegue = "TFLStationDetailMapViewControllerSegue"
    }
    @IBOutlet weak var heightConstraint : NSLayoutConstraint!
    @IBOutlet weak var titleHeaderView : TFLStationDetailHeaderView!
    var mapViewController : TFLStationDetailMapViewController?
    var tableViewController : TFLStationDetailTableViewController?
    lazy var backBarButtonItem : UIBarButtonItem = {
        let image = #imageLiteral(resourceName: "back")
        let button = UIButton(frame: CGRect(origin:.zero,size:image.size))
        button.addTarget(self, action: #selector(self.backBarButtonHandler), for: .touchUpInside)
        button.setImage(image, for: .normal)
        return UIBarButtonItem(customView: button)
    }()
    var line : String? = nil {
        didSet {
            guard let line = line else {
                return
            }
            let context = TFLBusStopStack.sharedDataStack.privateQueueManagedObjectContext
            context.perform {
                let lineInfo =  TFLCDLineInfo.lineInfo(with: line, and: context)
                let routes = lineInfo?.routes?.array as? [TFLCDLineRoute] ?? []
                let models : [TFLStationDetailTableViewModel] =  routes.compactMap { TFLStationDetailTableViewModel(with: $0) }
                let mapModels : [TFLStationDetailMapViewModel] = routes.compactMap { TFLStationDetailMapViewModel(with: $0) }
                OperationQueue.main.addOperation({
                    self.tableViewController?.viewModels = models
                    self.mapViewController?.viewModels = mapModels
                })
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleHeaderView.title = line ?? ""
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
        case .mapViewControllerSegue:
            mapViewController = segue.destination as? TFLStationDetailMapViewController
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
