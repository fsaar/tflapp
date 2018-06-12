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
    func didPanForHeaderView(_ headerView : TFLStationDetailSectionHeaderView,with distance : Float)
}

class TFLStationDetailSectionHeaderView: UITableViewHeaderFooterView {
    weak var delegate : TFLStationDetailSectionHeaderViewDelegate?
    var section : Int = 0
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
        switch gestureRecognizer.state {
        case .began:
            print("began")
            break
        case .changed:
            self.delegate?.didPanForHeaderView(self, with: 0)
            print("changed")
            break
        case .ended:
            print("ended")
            break
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
