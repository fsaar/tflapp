//
//  TFLStationDetailController.swift
//  tflapp
//
//  Created by Frank Saar on 29/05/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//

import UIKit
import CoreData

class TFLStationDetailController: UIViewController {
    enum SegueIdentifier : String {
        case tableViewControllerSegue =  "TFLStationDetailTableViewControllerSegue"
    }
    fileprivate var viewModels : [TFLStationDetailTableViewModel] = [] {
        didSet {
            self.tableViewController?.viewModels = viewModels
        }
    }
    @IBOutlet weak var titleHeaderView : TFLStationDetailHeaderView!
    var tableViewController : TFLStationDetailTableViewController?
    
    var line : String? = nil {
        didSet {
            guard let line = line else {
                return
            }
            let context = TFLBusStopStack.sharedDataStack.privateQueueManagedObjectContext
            context.perform {
                let lineInfo =  TFLCDLineInfo.lineInfo(with: line, and: context)
                let routes = lineInfo?.routes?.array as? [TFLCDLineRoute] ?? []
                var models : [TFLStationDetailTableViewModel] = []
                for route in routes {
                    let busStops = TFLCDBusStop.busStops(with: route.stations ?? [], and: context)
                    if !busStops.isEmpty {
                        let tuples = busStops.map { ($0.stopLetter ?? "",$0.name) }
                        let model = TFLStationDetailTableViewModel(routeName: route.name, stations: tuples)
                        models += [model]
                    }
                }
                OperationQueue.main.addOperation({
                    self.viewModels = models
                })
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleHeaderView.title = line ?? ""
        self.navigationItem.titleView = self.titleHeaderView

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier, let segueIdentifier = SegueIdentifier(rawValue: identifier) else {
            return
        }
        switch segueIdentifier {
        case .tableViewControllerSegue:
            tableViewController = segue.destination as? TFLStationDetailTableViewController
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
