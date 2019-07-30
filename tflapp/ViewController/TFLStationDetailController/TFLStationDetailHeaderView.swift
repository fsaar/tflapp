//
//  TFLStationDetailHeaderView.swift
//  tflapp
//
//  Created by Frank Saar on 29/05/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//

import UIKit

class TFLStationDetailHeaderView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
        updateColors()
    }
    
    @IBOutlet weak var backgroundImageView : UIImageView! = nil {
        didSet {
            self.backgroundImageView.image = self.titleBackgroundImage
            self.backgroundImageView.backgroundColor = .clear
        }
    }
    @IBOutlet weak var titleLabel : UILabel! = nil {
        didSet {
            self.titleLabel.font = .tflStationDetailHeader()
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

    lazy var titleBackgroundImage = backgroundImage()
        
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle else {
            return
        }
        updateColors()
    }
}

fileprivate extension TFLStationDetailHeaderView {
    func backgroundImage() -> UIImage {
        let bounds = self.backgroundImageView.bounds
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(bounds: bounds,format: format)
        return renderer.image { context in
          //  UIColor(named: "tflBackgroundColor")?.setFill()
            UIColor.clear.setFill()
            context.fill(bounds)
            
            let borderPath = UIBezierPath(roundedRect: bounds , cornerRadius: bounds.size.height/2)
            let bgColor = UIColor(named: "tflBusInfoBackgroundColor")
            bgColor?.setFill()
            borderPath.fill()
            
            let innerRect = bounds.insetBy(dx: 1, dy: 1)
            let busNumberRectPath = UIBezierPath(roundedRect: innerRect , cornerRadius: innerRect.size.height/2)
            UIColor(named: "tflLineBackgroundColor")?.setFill()
            UIColor(named: "tflLineBackgroundBorderColor")?.setStroke()
            busNumberRectPath.fill()
            busNumberRectPath.stroke()
        }
    }
    
    func updateColors() {
        self.titleLabel.textColor = UIColor(named:"tflSecondaryTextColor")
        self.titleBackgroundImage = backgroundImage()
        self.backgroundImageView.image = self.titleBackgroundImage
    }
}
