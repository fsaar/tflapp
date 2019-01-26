//
//  TFLHUD.swift
//  tflapp
//
//  Created by Frank Saar on 21/10/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//

import UIKit

class TFLHUD {
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
    
    private lazy var containerView : UIView = {
        let view = UIView(frame:.zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.clipsToBounds = true
        view.layer.cornerRadius = 20
        view.layer.borderColor = UIColor.red.cgColor
        view.layer.borderWidth = 2
        view.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return view
    }()
    
    private lazy var blurAnimator : UIViewPropertyAnimator = {
        let animator = UIViewPropertyAnimator(duration: 0.5, curve: .linear) {
            self.visualEffectsView.effect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        }
        animator.pauseAnimation()
        return animator
    }()
    
    private let visualEffectsView : UIVisualEffectView =  {
        let view = UIVisualEffectView(effect: nil)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isUserInteractionEnabled = false
        return view
    }()
    
    init() {
        setup()
    }
    deinit {
        visualEffectsView.removeFromSuperview()
        blurAnimator.stopAnimation(true)
    }
    
    private let indicator : UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(frame: .zero)
        indicator.style = UIActivityIndicatorView.Style.gray
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.startAnimating()
        return indicator
    }()
    
    static func show()  {
        if case .none = tflhud {
            tflhud = TFLHUD()
        }
        tflhud?.show()
    }
    
    static func hide()  {
        tflhud?.hide()
        tflhud = nil
    }
}

fileprivate extension TFLHUD {
    
    func show()  {
        guard let delegate  = UIApplication.shared.delegate as? AppDelegate,let window  = delegate.window else {
            return
        }
        window.isUserInteractionEnabled = false
        window.addSubview(self.visualEffectsView)

        NSLayoutConstraint.activate([
            visualEffectsView.leadingAnchor.constraint(equalTo: window.leadingAnchor),
            visualEffectsView.trailingAnchor.constraint(equalTo: window.trailingAnchor),
            visualEffectsView.bottomAnchor.constraint(equalTo: window.bottomAnchor),
            visualEffectsView.topAnchor.constraint(equalTo: window.topAnchor),
            ])
        blurAnimator.fractionComplete = 0.2
    }
    
    func hide() {
        let delegate  = UIApplication.shared.delegate as? AppDelegate
        let window  = delegate?.window
        window?.isUserInteractionEnabled = true
        blurAnimator.fractionComplete = 0
        visualEffectsView.removeFromSuperview()
    }
    
    func setup() {
        containerView.addSubview(label)
        containerView.addSubview(indicator)
        visualEffectsView.contentView.addSubview(containerView)

        NSLayoutConstraint.activate([
            containerView.centerYAnchor.constraint(equalTo: visualEffectsView.centerYAnchor),
            containerView.centerXAnchor.constraint(equalTo: visualEffectsView.centerXAnchor),

            label.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            indicator.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 20),
            indicator.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 0),
            indicator.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: 0)
        ])
    }
}
