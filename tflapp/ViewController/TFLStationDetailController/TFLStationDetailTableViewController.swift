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
    
    let sectionHeaderDefaultHeight = CGFloat(50)
   
    var viewModels : [TFLStationDetailTableViewModel] = [] {
        didSet {
            self.tableView.reloadData()
        }
    }
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.sectionHeaderHeight = sectionHeaderDefaultHeight
        let sectionNib = UINib(nibName: String(describing: TFLStationDetailSectionHeaderView.self), bundle: nil)
        self.tableView.register(sectionNib, forHeaderFooterViewReuseIdentifier: String(describing: TFLStationDetailSectionHeaderView.self))
    }
    
}

// MARK: UITableViewDataSource

extension TFLStationDetailTableViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModels.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let model = viewModels[section]
        return model.stations.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: TFLStationDetailSectionHeaderView.self)) as? TFLStationDetailSectionHeaderView
         let model = viewModels[section]
        header?.configure(with: model)
        return header
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TFLStationDetailTableViewCell.self), for: indexPath)
        if let cell = cell as? TFLStationDetailTableViewCell {
            let model = viewModels[indexPath.section]
            cell.configure(with: model,at:indexPath.row)
        }
        return cell
    }
}

