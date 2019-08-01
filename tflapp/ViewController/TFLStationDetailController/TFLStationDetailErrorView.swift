//
//  TFLStationDetailErrorView.swift
//  tflapp
//
//  Created by Frank Saar on 25/10/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//

import UIKit

class TFLStationDetailErrorView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
        updateColors()
    }
    
    @IBOutlet var title : UILabel! {
        didSet {
            title.font = UIFont.tflStationDetailErrorTitle()
            title.text = NSLocalizedString("TFLStationDetailErrorView.title", comment: "")
        }
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle else {
            return
        }
        updateColors()
    }
}

//
// MARK: - Private
//
fileprivate extension TFLStationDetailErrorView {
    func updateColors() {
        self.title.textColor = UIColor(named:"tflPrimaryTextColor")
        self.backgroundColor = UIColor(named: "tflBackgroundColor")
    }
}
