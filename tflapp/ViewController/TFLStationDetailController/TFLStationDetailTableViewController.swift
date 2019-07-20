//
//  TFLStationDetailTableViewController.swift
//  tflapp
//
//  Created by Frank Saar on 29/05/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//

import UIKit
import CoreData

protocol TFLStationDetailTableViewControllerDelegate : AnyObject {
    func tflStationDetailTableViewController(_ controller: TFLStationDetailTableViewController,didShowSection section: Int)
    func tflStationDetailTableViewController(_ controller: TFLStationDetailTableViewController,with header: UITableViewHeaderFooterView, didPanBy distance: CGFloat)
    func tflStationDetailTableViewController(_ controller: TFLStationDetailTableViewController,didSelectBusstopWith identifier: String)
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
    lazy var lightImpactFeedbackGenerator : UIImpactFeedbackGenerator? = UIImpactFeedbackGenerator(style: .light)
    fileprivate var visibleSections : Set<Int> = [] {
        didSet {
            let newSection = visibleSections.min()
            let oldSection = oldValue.min()
            if  newSection != oldSection, let currentSection = newSection {
                self.currentSection = currentSection
                if !oldValue.isEmpty {
                    self.lightImpactFeedbackGenerator?.prepare()
                    self.lightImpactFeedbackGenerator?.impactOccurred()
                }
            }
        }
    }
    var station : String?
    fileprivate var arrivalInfos : [TFLVehicleArrivalInfo] = []
    fileprivate var viewModels : [TFLStationDetailTableViewModel] = []
    fileprivate var line : String?
    func updateData(with newModels: [TFLStationDetailTableViewModel]? = nil,newArrivalInfos : [TFLVehicleArrivalInfo]? = nil,
                    for line: String? = nil) {
        self.line = line
        guard (newModels != nil) || (newArrivalInfos != nil) else {
            return
        }
        if let newModels = newModels {
            viewModels = newModels
        }

        let oldArrivalInfos = arrivalInfos
        if let newArrivalInfos = newArrivalInfos {
            arrivalInfos = newArrivalInfos
        }
        
        let animated = !oldArrivalInfos.isEmpty
        self.reloadAnimated(animated, oldArrivalInfos: oldArrivalInfos)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.sectionHeaderHeight = sectionHeaderDefaultHeight
        self.tableView.rowHeight = UITableView.automaticDimension
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
        configure(cell: cell as? TFLStationDetailTableViewCell, at: indexPath)
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = viewModels[indexPath.section]
        let identifier = model.stations[indexPath.row].naptanId
        delegate?.tflStationDetailTableViewController(self, didSelectBusstopWith: identifier)
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

fileprivate extension TFLStationDetailTableViewController {
    func reloadAnimated(_ animated : Bool,oldArrivalInfos : [TFLVehicleArrivalInfo]) {
        guard animated else {
            self.tableView.reloadData()
            self.scrollToStationIfNeedBe(self.station)
            return
        }
        let (inserted ,deleted ,updated, _) = oldArrivalInfos.transformTo(newList: arrivalInfos)
        guard !updated.isEmpty || inserted.isEmpty else {
            self.tableView.reloadData()
            self.scrollToStationIfNeedBe(self.station)
            return
        }
        
        let reloadList  = (inserted + deleted).map { $0.0 }
        let updateList = updated.map { $0.0 }
        
        let indexPathsToReload  = viewModels.indexPaths(for: reloadList)
        let visibleIndexPathSet = Set(self.tableView.indexPathsForVisibleRows ?? [])
        let indexPathsSetToUpdate = Set(viewModels.indexPaths(for: updateList)).intersection(visibleIndexPathSet)
            indexPathsSetToUpdate.forEach  { indexPath in
                guard let cell = self.tableView.cellForRow(at: indexPath) as? TFLStationDetailTableViewCell else {
                    return
                }
                self.configure(cell: cell, at: indexPath)
            }
            self.tableView.reloadRows(at: indexPathsToReload  , with: .automatic)
    }
    
    func configure(cell : TFLStationDetailTableViewCell?,at indexPath : IndexPath) {
        guard let cell = cell else {
            return
        }
        let model = viewModels[indexPath.section]
        let stationNaptanId = model.stations[indexPath.row].naptanId
        let highlight = stationNaptanId == self.station
        let arrivalInfo = arrivalInfos.info(with:stationNaptanId)
        cell.configure(with: model,and:arrivalInfo,for :line, at:indexPath.row,highlight: highlight)
    }
    
    func scrollToStationIfNeedBe(_ station : String?) {
        if let station = station , let indexPath = viewModels.indexPath(for:station) {
            performWithoutFeedbackGenerator { [weak self] in
                UIView.performWithoutAnimation {
                    self?.currentSection = indexPath.section
                    self?.tableView.scrollToRow(at: indexPath, at: UITableView.ScrollPosition.bottom, animated: false)
                }
            }
            
        }
    }
    
    func performWithoutFeedbackGenerator(using block : @escaping () -> Void) {
        var oldValue : UIImpactFeedbackGenerator?
        (oldValue, self.lightImpactFeedbackGenerator) = (self.lightImpactFeedbackGenerator,oldValue)
        block()
        OperationQueue.main.addOperation {
            self.lightImpactFeedbackGenerator = oldValue
        }
    }

}

extension TFLStationDetailTableViewController : TFLStationDetailMapViewControllerDelegate {
    func stationDetailMapViewController(_ stationDetailMapViewController : TFLStationDetailMapViewController,didSelectStationWith identifier : String) {
        guard currentSection < viewModels.count else {
            return
        }
        let model = viewModels[currentSection]
        guard let row = model.stations.firstIndex (where:{ $0.naptanId == identifier }) else {
            return
        }
        let indexPath = IndexPath(row: row, section: currentSection)
        self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
    }
}
