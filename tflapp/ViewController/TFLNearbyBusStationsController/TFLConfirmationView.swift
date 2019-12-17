//
//  TFLInformationView.swift
//  tflapp
//
//  Created by Frank Saar on 12/12/2019.
//  Copyright © 2019 SAMedialabs. All rights reserved.
//

import UIKit

class TFLInformationView: UIView {
    enum InformationType {
        case confirmation
        case notification(stationName : String,line : String)
        
        var title : String {
            switch self {
            case .confirmation:
                return NSLocalizedString("TFLInformationView.title", comment: "")
            case .notification(let stationName,let line):
                let title = String(format:NSLocalizedString("TFLInformationView.notification", comment: ""),line,stationName)
                return title
            }
        }
        var image : UIImage? {
            switch self {
            case .confirmation:
                return UIImage(systemName: "checkmark.circle")
            case .notification:
                return UIImage(systemName: "info.circle")
            }
        }
    }
    @IBOutlet weak var imageView : UIImageView! {
        didSet {
            self.imageView.image = self.type.image
        }
    }
    @IBOutlet weak var topBorderLine : UIView!
    @IBOutlet weak var titleLabel : UILabel! {
        didSet {
            self.titleLabel.text = self.type.title
            self.titleLabel.font = UIFont.tflInformationViewTitle()
        }
    }
    var type : InformationType = .confirmation {
        didSet {
            self.titleLabel.text = self.type.title
            self.imageView.image = type.image ?? UIImage()
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

extension TFLInformationView {
    func updateColors() {
        self.backgroundColor = UIColor(named:"tflConfirmationViewBackgroundColor")
        self.titleLabel.textColor = UIColor(named:"tflConfirmationViewTextColor")
        self.imageView.tintColor = UIColor(named:"tflConfirmationViewTextColor")
        self.topBorderLine.backgroundColor = UIColor(named:"tflConfirmationViewBorderColor")
    }
}
