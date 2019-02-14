//
//  TFLOfflineView.swift
//  tflapp
//
//  Created by Frank Saar on 11/02/2019.
//  Copyright © 2019 SAMedialabs. All rights reserved.
//

import Foundation
import UIKit

class TFLOfflineView : UIView {
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
}
