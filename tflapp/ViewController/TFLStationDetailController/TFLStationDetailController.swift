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

    fileprivate var stations : [TFLCDStation] = [] {
        didSet {
            print(stations.compactMap { $0.name })
        }
    }
    @IBOutlet weak var titleHeaderView : TFLStationDetailHeaderView!
    
    
    var line : String? = nil {
        didSet {
            guard let line = line else {
                return
            }
            let context = TFLBusStopStack.sharedDataStack.privateQueueManagedObjectContext
            context.perform {
                let lineInfo =  TFLCDLineInfo.lineInfo(with: line, and: context)
                let stations = lineInfo?.stations?.array as? [TFLCDStation] ?? []
                let mainContext = TFLBusStopStack.sharedDataStack.mainQueueManagedObjectContext
                mainContext.perform {
                    self.stations =  (stations.map { mainContext.object(with: $0.objectID) } as? [TFLCDStation]) ?? []
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.titleHeaderView.title = line ?? ""
        self.navigationItem.titleView = self.titleHeaderView

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
}
