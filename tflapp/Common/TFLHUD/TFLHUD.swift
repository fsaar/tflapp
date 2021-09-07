//
//  TFLHUD.swift
//  tflapp
//
//  Created by Frank Saar on 21/10/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//

import UIKit

class TFLHUDContainerView : UIView {
    var traitCollectionDidChangeBlock : ((_ previousTraitCollection: UITraitCollection?) -> Void)?
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle else {
            return
        }
        traitCollectionDidChangeBlock?(previousTraitCollection)
    }
}


class TFLHUD {
    private static var tflhud : TFLHUD? = nil
    private let label : UILabel = {
        let label =  UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("TFLHUD.title", comment: "")
        label.backgroundColor = .white
        label.textColor = .black
        label.font = UIFont.tflHUDTitle()
        label.isAccessibilityElement = false
        return label
    }()
    
    private lazy var containerView : UIView = {
        let view = TFLHUDContainerView()
        view.traitCollectionDidChangeBlock = { [weak self] _ in
            self?.updateColors()
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.cornerRadius = 20
        view.layer.borderWidth = 2
        let color = UIColor(named:"tflHUDBorderColor")
        view.layer.borderColor = color?.resolvedColor(with:view.traitCollection).cgColor
        view.heightAnchor.constraint(equalToConstant: 40).isActive = true
        view.isAccessibilityElement = true
        view.accessibilityLabel = NSLocalizedString("TFLHUD.accessiblityTitle", comment: "")
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
        let indicator = UIActivityIndicatorView()
        indicator.style = UIActivityIndicatorView.Style.medium
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
    func updateColors() {
        self.containerView.backgroundColor = UIColor(named:"tflBackgroundColor")
        self.containerView.layer.borderColor = UIColor(named:"tflHUDBorderColor")?.cgColor ?? UIColor.white.cgColor
        self.label.backgroundColor = UIColor(named:"tflBackgroundColor")
        self.label.textColor =  UIColor(named:"tflPrimaryTextColor")
        self.indicator.color = UIColor(named:"tflRefreshColor")
    }
    
    
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
        updateColors()
    }
}
