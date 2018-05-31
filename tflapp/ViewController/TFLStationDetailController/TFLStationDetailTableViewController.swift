//
//  TFLStationDetailTableViewController.swift
//  tflapp
//
//  Created by Frank Saar on 29/05/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//

import UIKit
import CoreData

class TFLStationDetailTableViewController: UITableViewController {

    var viewModels : [TFLStationDetailTableViewModel] = [] {
        didSet {
            self.tableView.reloadData() 
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

// MARK: UITableViewDataSource

extension TFLStationDetailTableViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TFLStationDetailTableViewCell.self), for: indexPath)
        if let cell = cell as? TFLStationDetailTableViewCell {
            cell.configure(with: viewModels[indexPath.row])
        }
        return cell
    }
}
