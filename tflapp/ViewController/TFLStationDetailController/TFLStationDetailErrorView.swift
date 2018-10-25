//
//  TFLStationDetailErrorView.swift
//  tflapp
//
//  Created by Frank Saar on 25/10/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//

import UIKit

class TFLStationDetailErrorView: UIView {

    @IBOutlet var title : UILabel! {
        didSet {
            title.font = UIFont.tflStationDetailErrorTitle()
            title.text = NSLocalizedString("TFLStationDetailErrorView.title", comment: "")
        }
    }
    
}
