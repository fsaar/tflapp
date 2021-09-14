//
//  TFLOfflineView.swift
//  tflapp
//
//  Created by Frank Saar on 11/02/2019.
//  Copyright © 2019 SAMedialabs. All rights reserved.
//

import Foundation
import UIKit

@MainActor
class TFLOfflineView : UIView {
    @MainActor override func awakeFromNib() {
        super.awakeFromNib()
        updateColors()
    }
    
    @IBOutlet weak var titleLabel : UILabel! {
        didSet {
            self.titleLabel.font = UIFont.tflOfflineTitle()
            self.titleLabel.text = NSLocalizedString("TFLOfflineView.offline.title",comment: "")
        }
    }
    @IBOutlet weak var imageView : UIImageView! {
        didSet {
            self.imageView.tintColor = UIColor.white
            
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


fileprivate extension TFLOfflineView {
    
    func updateColors() {
        self.titleLabel.textColor = UIColor(named: "tflOfflineViewTextColor")
        self.titleLabel.backgroundColor = UIColor(named: "tflOfflineViewBackgroundColor")
        self.imageView.tintColor =  UIColor(named: "tflOfflineViewTextColor")
        self.backgroundColor =  UIColor(named: "tflOfflineViewBackgroundColor")
        
    }
}
