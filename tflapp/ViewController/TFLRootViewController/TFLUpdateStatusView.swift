//
//  TFLUpdateStatusView.swift
//  tflapp
//
//  Created by Frank Saar on 01/12/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//

import Foundation
import UIKit

protocol TFLUpdateStatusViewDelegate : class {
    func didExpireTimerInStatusView(_ tflStatusView : TFLUpdateStatusView)
}



class TFLUpdateStatusView : UIView {
    weak var delegate : TFLUpdateStatusViewDelegate?
    enum Style {
        case compact
        case detailed
    }
    enum State : Int {
        case updating
        case updatePending
        case paused
    }
    fileprivate var refreshInterval = 60
    fileprivate var style = Style.detailed
    
    func showPropertyAnimator() -> UIViewPropertyAnimator  {
        let animator = UIViewPropertyAnimator(duration: 0.25, curve: UIView.AnimationCurve.linear)
        return animator
    }
    func hidePropertyAnimator() -> UIViewPropertyAnimator  {
        let animator = UIViewPropertyAnimator(duration: 0.1, curve: UIView.AnimationCurve.linear)
        return animator
    }
    var hideAnimator : UIViewPropertyAnimator?
    var showAnimator : UIViewPropertyAnimator?
    var state = State.updating {
        didSet {
            guard oldValue != state else {
                return
            }
            
            showAnimator?.stopAnimation(true)
            hideAnimator?.stopAnimation(true)
            hideAnimator = hidePropertyAnimator()
            showAnimator = showPropertyAnimator()
            switch state {
            case .updating:
                hideAnimator?.addAnimations {
                    self.updatePendingStateContainerView.alpha = 0
                }
                showAnimator?.addAnimations {
                    self.updatingStateContainerView.alpha = 1
                }
                hideAnimator?.addCompletion { _ in
                    self.timerView.reset()
                    self.showAnimator?.startAnimation()
                }
                hideAnimator?.startAnimation()
            case .updatePending:
                hideAnimator?.addAnimations {
                    self.updatingStateContainerView.alpha = 0
                }
                showAnimator?.addAnimations {
                    self.updatePendingStateContainerView.alpha = 1
                }
                hideAnimator?.addCompletion {  _ in
                    self.showAnimator?.startAnimation()
                }
                showAnimator?.addCompletion { _ in
                    self.timerView.start()
                }
                hideAnimator?.startAnimation()
            case .paused:
                self.updatingStateContainerView.alpha = 0
                self.updatePendingStateContainerView.alpha = 0
                self.timerView.reset()
            }
        }
    }
    lazy var timerView : TFLTimerView = {
        let timerView = TFLTimerView(expiryTimeInSecods: self.refreshInterval)
        timerView.translatesAutoresizingMaskIntoConstraints = false
        timerView.delegate = self
        return timerView
    }()
    
    lazy var updatingStateLabel : UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("TFLUpdateStatusView.pending.title", comment: "")
        label.backgroundColor = .clear
        label.textColor = .white
        label.font = UIFont.tflUpdateStatusPendingTitle()
        return label
    }()
    lazy var updatingStateIndicatorView : UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.white)
        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        indicatorView.startAnimating()
        return indicatorView
    }()
    
    fileprivate lazy var updatingStateContainerView : UIView = {
        let view = UIView(frame:.zero)
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        switch style {
        case .detailed:
            view.addSubview(updatingStateLabel)
            view.addSubview(updatingStateIndicatorView)
            NSLayoutConstraint.activate([
                updatingStateLabel.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor),
                updatingStateLabel.trailingAnchor.constraint(equalTo: updatingStateIndicatorView.leadingAnchor,constant:-10),
                updatingStateLabel.centerYAnchor.constraint(equalTo:view.centerYAnchor),
                updatingStateIndicatorView.centerYAnchor.constraint(equalTo:view.centerYAnchor),
                updatingStateIndicatorView.trailingAnchor.constraint(equalTo:view.trailingAnchor)
                ])
        case .compact:
            view.addSubview(updatingStateIndicatorView)
            NSLayoutConstraint.activate([
                updatingStateIndicatorView.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor),
                updatingStateIndicatorView.centerYAnchor.constraint(equalTo:view.centerYAnchor),
                updatingStateIndicatorView.trailingAnchor.constraint(equalTo:view.trailingAnchor)
                ])
        }
        return view
    }()
    
    fileprivate lazy var updatePendingStateContainerView : UIView = {
        let view = UIView(frame:.zero)
        view.alpha = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.addSubview(self.timerView)
        NSLayoutConstraint.activate([
            timerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            timerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            timerView.topAnchor.constraint(equalTo: view.topAnchor),
            timerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            ])
        return view
    }()
    
    init(style: Style,refreshInterval : Int) {
        super.init(frame: .zero)
        self.refreshInterval = refreshInterval
        self.style = style
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
}

fileprivate extension TFLUpdateStatusView {
    func setup() {
        self.backgroundColor = .clear
        self.addSubview(updatePendingStateContainerView)
        self.addSubview(updatingStateContainerView)
        NSLayoutConstraint.activate([
            updatePendingStateContainerView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            updatePendingStateContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            
            updatingStateContainerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            updatingStateContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            updatingStateContainerView.topAnchor.constraint(equalTo:self.topAnchor),
            updatingStateContainerView.bottomAnchor.constraint(equalTo:self.bottomAnchor)
            ])
        self.state = .paused
    }
    
}


extension TFLUpdateStatusView : TFLTimerViewDelegate {
    func tflTimerViewDidExpire(_ timerView : TFLTimerView) {
        self.delegate?.didExpireTimerInStatusView(self)
    }
}
