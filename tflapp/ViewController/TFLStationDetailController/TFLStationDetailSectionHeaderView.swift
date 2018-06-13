//
//  TFLStationDetailSectionHeaderView.swift
//  tflapp
//
//  Created by Frank Saar on 29/05/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//
import Foundation
import UIKit

protocol TFLStationDetailSectionHeaderViewDelegate : class {
    func panEnabledForHeaderView(_ headerView : TFLStationDetailSectionHeaderView) -> Bool
    func didPanForHeaderView(_ headerView : TFLStationDetailSectionHeaderView,with distance : CGFloat)
}

class TFLStationDetailSectionHeaderView: UITableViewHeaderFooterView {
    weak var delegate : TFLStationDetailSectionHeaderViewDelegate?
    var section : Int = 0
    var oldValue : CGFloat = 0
    var startPanY : CGFloat = 0
    @IBOutlet weak var titleLabel : UILabel! = nil {
        didSet {
            self.titleLabel.font = UIFont.tflStationDetailSectionHeaderTitle()
            self.titleLabel.textColor = UIColor.black
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler(_:)))
        recognizer.delegate = self
        self.addGestureRecognizer(recognizer)
    }
    
    override func prepareForReuse() {
        self.titleLabel.text = nil
    }
    
    func configure(with model: TFLStationDetailTableViewModel, for section: Int) {
        self.titleLabel.text = model.routeName
        self.section = section
    }
    
    @objc func panGestureHandler(_ gestureRecognizer: UIPanGestureRecognizer) {
        let p = gestureRecognizer.location(in: self.window)
        switch gestureRecognizer.state {
        case .began:
            startPanY = p.y
        case .changed:
            let distance = p.y - startPanY
            self.delegate?.didPanForHeaderView(self, with: distance)
            startPanY =  p.y
        default:
            break
        }
    }
}

extension TFLStationDetailSectionHeaderView : UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let panEnabled = self.delegate?.panEnabledForHeaderView(self) ?? false
        return panEnabled
    }
}
