//
//  TFLStationDetailHeaderView.swift
//  tflapp
//
//  Created by Frank Saar on 29/05/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//

import UIKit

class TFLStationDetailHeaderView: UIView {

    @IBOutlet weak var backgroundImageView : UIImageView! = nil {
        didSet {
            self.backgroundImageView.image = self.titleBackgroundImage
            self.backgroundImageView.backgroundColor = .clear
        }
    }
    @IBOutlet weak var titleLabel : UILabel! = nil {
        didSet {
            self.titleLabel.font = .tflStationDetailHeader()
            self.titleLabel.textColor = .white
        }
    }

    var title : String?  {
        set {
            self.titleLabel.text  = newValue
        }
        get {
            return self.titleLabel.text
        }
    }


    var titleBackgroundImage: UIImage {
        let bounds = self.backgroundImageView.bounds
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(bounds: bounds,format: format)
        return renderer.image { context in
            UIColor.clear.setFill()
            context.fill(bounds)

            let borderPath = UIBezierPath(roundedRect: bounds , cornerRadius: bounds.size.height/2)
            UIColor.white.setFill()
            borderPath.fill()

            let innerRect = bounds.insetBy(dx: 1, dy: 1)
            let busNumberRectPath = UIBezierPath(roundedRect: innerRect , cornerRadius: innerRect.size.height/2)
            UIColor.red.setFill()
            UIColor.white.setStroke()
            busNumberRectPath.fill()
            busNumberRectPath.stroke()
        }
    }

}
