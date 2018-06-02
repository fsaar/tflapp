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
    enum SectionState {
        case open(model : TFLStationDetailTableViewModel)
        case closed(model : TFLStationDetailTableViewModel)
        
        var inverse : SectionState {
            switch self {
            case .open(let model):
                return .closed(model: model)
                
            case .closed(let model):
                return .open(model: model)
            }
        }
    }
    
    let sectionHeaderDefaultHeight = CGFloat(50)
    var tableViewModel : [SectionState] = [] {
        didSet {
            self.tableView.reloadData()
        }

    }
    var viewModels : [TFLStationDetailTableViewModel] = [] {
        didSet {
            self.tableViewModel = self.viewModels.map {SectionState.closed(model: $0) }
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
        let model = tableViewModel[section]
        switch model {
        case .open(let viewModel):
            return viewModel.stations.count
        case .closed:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: TFLStationDetailSectionHeaderView.self)) as? TFLStationDetailSectionHeaderView
         let model = viewModels[section]
        header?.configure(with: model) { [weak self] in
            self?.didTap(section: section)
        }
        return header
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: TFLStationDetailTableViewCell.self), for: indexPath)
        if let cell = cell as? TFLStationDetailTableViewCell {
            let model = tableViewModel[indexPath.section]
            if case let .open(viewModel) = model {
                cell.configure(with: viewModel,at:indexPath.row)
            }
        }
        return cell
    }
}
// MARK: Private
private extension TFLStationDetailTableViewController {
    func didTap(section : Int) {
        let model = tableViewModel[section]
        tableView.beginUpdates()
        tableViewModel[section] = model.inverse
        switch tableViewModel[section] {
        case .closed(let viewModel):
            let indexPaths = (0..<viewModel.stations.count).map { IndexPath(row: $0, section:section ) }
            tableView.deleteRows(at: indexPaths, with: .fade)
        case .open(let viewModel):
            let indexPaths = (0..<viewModel.stations.count).map { IndexPath(row: $0, section:section ) }
            tableView.insertRows(at: indexPaths, with: .fade)
        }
        tableView.endUpdates()
    }
}
