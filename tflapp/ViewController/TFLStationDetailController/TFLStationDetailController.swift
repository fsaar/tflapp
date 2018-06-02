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
    }
    fileprivate var viewModels : [TFLStationDetailTableViewModel] = [] {
        didSet {
            self.tableViewController?.viewModels = viewModels
        }
    }
    @IBOutlet weak var titleHeaderView : TFLStationDetailHeaderView!
    var tableViewController : TFLStationDetailTableViewController?
    lazy var backBarButtonItem : UIBarButtonItem = {
        let button = UIButton(frame: CGRect(x:0,y:0,width:40,height:40))
        button.addTarget(self, action: #selector(self.backBarButtonHandler), for: .touchUpInside)
        button.tintColor = .red
        let image = #imageLiteral(resourceName:"back")
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
        self.navigationItem.leftBarButtonItem = self.backBarButtonItem
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
/// MARK: Private
fileprivate extension TFLStationDetailController {
    @objc func backBarButtonHandler() {
        self.navigationController?.popViewController(animated: true)
    }
}
