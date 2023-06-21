//
//  TFLStationDetailSectionHeaderView.swift
//  tflapp
//
//  Created by Frank Saar on 29/05/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//
import Foundation
import UIKit

protocol TFLStationDetailSectionHeaderViewDelegate : AnyObject {
    func panEnabledForHeaderView(_ headerView : TFLStationDetailSectionHeaderView) -> Bool
    func didPanForHeaderView(_ headerView : TFLStationDetailSectionHeaderView,with distance : CGFloat)
}

class TFLStationDetailSectionHeaderView: UITableViewHeaderFooterView {
    weak var delegate : TFLStationDetailSectionHeaderViewDelegate?
    var section : Int = 0
    var startPanY : CGFloat = 0
    @IBOutlet weak var barView : UIImageView!
    @IBOutlet weak var upperSeparator : UIView!
    @IBOutlet weak var lowerSeparator : UIView!
    @IBOutlet weak var titleLabel : UILabel! = nil {
        didSet {
            self.titleLabel.font = UIFont.tflStationDetailSectionHeaderTitle()
            self.titleLabel.textColor = .black
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.isOpaque = true
        self.contentView.isOpaque = true
        self.barView.alpha = 0
        let recognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler(_:)))
        recognizer.delegate = self
        self.addGestureRecognizer(recognizer)
        updateColors()
        prepareForReuse()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.titleLabel.text = nil
        self.barView.alpha = 0
    }

    func configure(with model: TFLStationDetailTableViewModel, for section: Int,and indicatorVisible : Bool ) {
        self.titleLabel.text = model.routeName
        self.section = section
        showBarView(indicatorVisible, animated: false)
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

    func showBarView(_ show: Bool, animated: Bool = true) {
        let duration = animated ? 0.5 : 0.0
        UIView.animate(withDuration: duration) {
            self.barView.alpha = show ? 1.0 : 0.0
        }
    }
    
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//        guard traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle else {
//            return
//        }
//        updateColors()
//    }
       
}

extension TFLStationDetailSectionHeaderView : UIGestureRecognizerDelegate {
    func updateColors() {
        self.titleLabel.textColor = UIColor(named: "tflStationDetailHeaderBarColor")
        self.barView.tintColor = UIColor(named: "tflStationDetailHeaderBarColor")
        self.backgroundColor = UIColor(named: "tflStationDetailHeaderBackgroundColor")
        self.contentView.backgroundColor = UIColor(named: "tflStationDetailHeaderBackgroundColor")
        self.upperSeparator.backgroundColor = UIColor(named: "tflStationDetailHeaderBarColor")
        self.lowerSeparator.backgroundColor = UIColor(named: "tflStationDetailHeaderBarColor")
    }
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let panEnabled = self.delegate?.panEnabledForHeaderView(self) ?? false
        return panEnabled
    }
}
