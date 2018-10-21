//
//  TFLHUD.swift
//  tflapp
//
//  Created by Frank Saar on 21/10/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//

import UIKit

class TFLHUD: UIView {
    private static var tflhud : TFLHUD? = nil
    private let label : UILabel = {
        let label =  UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("TFLHUD.title", comment: "")
        label.backgroundColor = .white
        label.textColor = .black
        label.font = UIFont.tflHUDTitle()
        return label
    }()
    
    private lazy var hideAnimator : UIViewPropertyAnimator = {
        let animator = UIViewPropertyAnimator(duration: 0.5, curve: .linear) {
            self.alpha =  0
        }
        animator.addCompletion { [weak self] _ in
            self?.window?.isUserInteractionEnabled = true
            self?.indicator.stopAnimating()
            self?.removeFromSuperview()
        }
        return animator
    }()
    
    private lazy var showAnimator : UIViewPropertyAnimator = {
        let springParameters = UISpringTimingParameters(dampingRatio: 0.5)
        let animator = UIViewPropertyAnimator(duration: 0.5, timingParameters: springParameters)
        animator.addAnimations {
            self.transform = CGAffineTransform.identity
        }
        return animator
    }()
    
    private let indicator : UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(frame: .zero)
        indicator.style = UIActivityIndicatorView.Style.gray
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    static func show(_ animated : Bool = true)  {
        guard case .none = tflhud else {
            return
        }
        tflhud = TFLHUD()
        tflhud?.show(animated)
    }
    
    static func hide(_ animated : Bool = true)  {
        tflhud?.hide()
        tflhud = nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

}

fileprivate extension TFLHUD {
    
    func show(_ animated : Bool = true)  {
        guard let delegate  = UIApplication.shared.delegate as? AppDelegate,let window  = delegate.window else {
            return
        }
        window.addSubview(self)
        NSLayoutConstraint.activate([
            self.centerYAnchor.constraint(equalTo: window.centerYAnchor),
            self.centerXAnchor.constraint(equalTo: window.centerXAnchor)
            ])
        
        window.isUserInteractionEnabled = false
        indicator.startAnimating()
        self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        showAnimator.fractionComplete = animated ? 0.0 : 1.0
        showAnimator.startAnimation()
    }
    
    func hide(_ animated : Bool = true) {
        hideAnimator.fractionComplete = animated ? 0.0 : 1.0
        hideAnimator.startAnimation()
    }
    
    func setup() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundColor = .white
        self.clipsToBounds = true
        self.layer.cornerRadius = 20
        self.layer.borderColor = UIColor.red.cgColor
        self.layer.borderWidth = 2
        
        self.addSubview(label)
        self.addSubview(indicator)
        
        NSLayoutConstraint.activate([
            self.heightAnchor.constraint(equalToConstant: 40),
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            indicator.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 20),
            indicator.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0),
            indicator.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0)
        ])
    }
}
