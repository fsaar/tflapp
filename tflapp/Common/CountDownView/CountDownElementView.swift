//
//  CountDownLabel.swift
//  CountDownLabel
//
//  Created by Frank Saar on 18/12/2019.
//  Copyright © 2019 Frank Saar. All rights reserved.
//

import UIKit

class CountDownElementView : UIView {
    fileprivate lazy var lowerLabel = self.label()
    fileprivate lazy var upperLabel = self.label()
    fileprivate var lowerLabelTopConstraint : NSLayoutConstraint?
    fileprivate var propertyAnimator : UIViewPropertyAnimator = {
        let springTimimgs = UISpringTimingParameters(dampingRatio:0.5)
        let animator = UIViewPropertyAnimator(duration: 0.5, timingParameters: springTimimgs)
        return animator
    }()

    
    init() {
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    var text : String?  {
        didSet {
            self.lowerLabel.text = text
        }
    }
    
    var font : UIFont = UIFont.systemFont(ofSize: 14) {
        didSet {
            self.lowerLabel.font = font
            self.upperLabel.font = font
        }
    }
    
    var textColor : UIColor? = .white {
        didSet {
            self.lowerLabel.textColor = textColor
            self.upperLabel.textColor = textColor
        }
    }
    
    func animateWithInterval(_ interval : TimeInterval,newText : String?,using completionBlock: (() -> Void)? = nil) {
        self.upperLabel.text = newText
        propertyAnimator.addAnimations {
            self.lowerLabelTopConstraint?.constant = self.frame.size.height
            self.layoutIfNeeded()
        }

        propertyAnimator.addCompletion { _ in
            self.text = self.upperLabel.text
            self.lowerLabelTopConstraint?.constant = 0
            self.layoutIfNeeded()
            completionBlock?()
        }
        propertyAnimator.startAnimation()
    }
    
}

//
// MARK: - CountDownElementView
//
fileprivate extension CountDownElementView {
    func label() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = false
        label.numberOfLines = 1
        label.backgroundColor = UIColor.clear
        label.textColor = .black
        label.textAlignment = .center
        label.text = nil
        label.font = font
        return label
    }
    
    func setup() {
        self.backgroundColor = .clear
        self.clipsToBounds = true
        self.addSubview(upperLabel)
        self.addSubview(lowerLabel)
        NSLayoutConstraint.activate([
            lowerLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            lowerLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            lowerLabel.heightAnchor.constraint(equalTo: self.heightAnchor),
            upperLabel.leadingAnchor.constraint(equalTo:self.leadingAnchor),
            upperLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            upperLabel.heightAnchor.constraint(equalTo: self.heightAnchor),
            upperLabel.bottomAnchor.constraint(equalTo: lowerLabel.topAnchor)
        ])
        let constraint = NSLayoutConstraint(item: self.lowerLabel, attribute:.top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0)
        self.addConstraint(constraint)
        self.lowerLabelTopConstraint = constraint
    }
}
