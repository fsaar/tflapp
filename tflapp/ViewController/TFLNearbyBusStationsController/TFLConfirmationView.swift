//
//  TFLConfirmationView.swift
//  tflapp
//
//  Created by Frank Saar on 12/12/2019.
//  Copyright © 2019 SAMedialabs. All rights reserved.
//

import UIKit

class TFLConfirmationView: UIView {
    @IBOutlet weak var imageView : UIImageView!
    @IBOutlet weak var topBorderLine : UIView!
    @IBOutlet weak var titleLabel : UILabel! {
        didSet {
            self.titleLabel.text = NSLocalizedString("TFLConfirmationView.title", comment: "")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateColors()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateColors()
    }
}

extension TFLConfirmationView {
    func updateColors() {
        self.backgroundColor = UIColor(named:"tflConfirmationViewBackgroundColor")
        self.titleLabel.textColor = UIColor(named:"tflConfirmationViewTextColor")
        self.imageView.tintColor = UIColor(named:"tflConfirmationViewTextColor")
        self.topBorderLine.backgroundColor = UIColor(named:"tflConfirmationViewBorderColor")
    }
}
