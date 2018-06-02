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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        let tapHandler = UITapGestureRecognizer(target: self, action: #selector(self.didTapSection))
        self.addGestureRecognizer(tapHandler)
    }
    
    override func prepareForReuse() {
        self.titleLabel.text = nil
    }

    var tapHandler : (()->())?
    func configure(with model: TFLStationDetailTableViewModel, using tapHandler: (()->())? = nil) {
        let attributedString = (try? NSMutableAttributedString(data:  model.routeName.data(using: .utf8)!, options:[.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)) ?? NSMutableAttributedString(string: "")
        attributedString.setAttributes([NSAttributedStringKey.font : UIFont.tflStationDetailSectionHeaderTitle(),NSAttributedStringKey.foregroundColor: UIColor.black], range: NSMakeRange(0,attributedString.length))
        self.titleLabel.attributedText = attributedString
        self.tapHandler = tapHandler
    }
    
    @objc func didTapSection() {
        tapHandler?()
    }
    
}
