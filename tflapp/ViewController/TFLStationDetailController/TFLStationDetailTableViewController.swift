//
//  TFLStationDetailTableViewController.swift
//  tflapp
//
//  Created by Frank Saar on 29/05/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//

import UIKit
import CoreData

protocol TFLStationDetailTableViewControllerDelegate : class {
    func tflStationDetailTableViewController(_ controller: TFLStationDetailTableViewController,didShowSection section: Int)
    func tflStationDetailTableViewController(_ controller: TFLStationDetailTableViewController,with header: UITableViewHeaderFooterView, didPanBy distance: CGFloat)
}

class TFLStationDetailTableViewController: UITableViewController {
    weak var delegate : TFLStationDetailTableViewControllerDelegate?
    let sectionHeaderDefaultHeight = CGFloat(50)
    fileprivate var currentSection : Int = 0 {
        didSet {
            self.delegate?.tflStationDetailTableViewController(self, didShowSection: currentSection)
            self.tableView.bounces = currentSection  > 0
            showHeaderView(true,for: self.currentSection)
            showHeaderView(false,for: oldValue)
        }
    }
    
    func showHeaderView(_ show : Bool,for section: Int?) {
        guard let section = section else {
            return
        }
        let headerView = self.tableView.headerView(forSection: section) as? TFLStationDetailSectionHeaderView
        headerView?.showBarView(show, animated: true)
    }
    
    fileprivate var visibleSections : Set<Int> = [] {
        didSet {
            let newSection = visibleSections.min()
            let oldSection = oldValue.min()
            if  newSection != oldSection, let currentSection = newSection {
                self.currentSection = currentSection
            }
        }
    }
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
        header?.delegate = self
         let model = viewModels[section]
        header?.configure(with: model,for: section,and: section <= self.currentSection)
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

// MARK: UITableViewDelegate

extension TFLStationDetailTableViewController {
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        visibleSections = visibleSections.union([section])
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        visibleSections = visibleSections.subtracting([section])
    }
}

extension TFLStationDetailTableViewController : TFLStationDetailSectionHeaderViewDelegate {
    func panEnabledForHeaderView(_ headerView : TFLStationDetailSectionHeaderView) -> Bool {
        return headerView.section == self.currentSection
    }
    
    func didPanForHeaderView(_ headerView : TFLStationDetailSectionHeaderView,with distance : CGFloat) {
        self.delegate?.tflStationDetailTableViewController(self,with: headerView, didPanBy: distance)
    }
}
