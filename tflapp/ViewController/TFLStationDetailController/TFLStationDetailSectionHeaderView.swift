//
//  TFLStationDetailSectionHeaderView.swift
//  tflapp
//
//  Created by Frank Saar on 29/05/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//
import Foundation
import UIKit

class TFLStationDetailSectionHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var titleLabel : UILabel! = nil {
        didSet {
            self.titleLabel.font = UIFont.tflStationDetailSectionHeaderTitle()
            self.titleLabel.textColor = UIColor.black
        }
    }

    
    func configure(with model: TFLStationDetailTableViewModel) {
        let attributedText = NSMutableAttributedString(attributedString: model.routeName)
        attributedText.setAttributes([NSAttributedStringKey.font : UIFont.tflStationDetailSectionHeaderTitle(),NSAttributedStringKey.foregroundColor: UIColor.black], range: NSMakeRange(0,attributedText.length))
        self.titleLabel.attributedText = attributedText
    }
}
