//
//  TFLButton.swift
//  tflapp
//
//  Created by Frank Saar on 19/11/2016.
//  Copyright © 2016 SAMedialabs. All rights reserved.
//

import UIKit

class TFLButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 2.0
        self.layer.cornerRadius = 5
    }
    
//    override var intrinsicContentSize: CGSize {
//        let size = super.intrinsicContentSize
//        return CGSize(size.width + self.titl
//    }
}


