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
    var state = State.updating {
        didSet {
            switch state {
            case .updating:
                self.updatingStateContainerView.isHidden = false
                self.updatePendingStateContainerView.isHidden = true
                self.timerView.reset()
            case .updatePending:
                self.updatingStateContainerView.isHidden = true
                self.updatePendingStateContainerView.isHidden = false
                self.timerView.start()
            case .paused:
                self.updatingStateContainerView.isHidden = true
                self.updatePendingStateContainerView.isHidden = true
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
        view.isHidden = true
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
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.addSubview(self.timerView)
        NSLayoutConstraint.activate([
            timerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            timerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
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
            updatePendingStateContainerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            updatePendingStateContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            updatePendingStateContainerView.topAnchor.constraint(equalTo:self.topAnchor),
            updatePendingStateContainerView.bottomAnchor.constraint(equalTo:self.bottomAnchor),
            
            updatingStateContainerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            updatingStateContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            updatingStateContainerView.topAnchor.constraint(equalTo:self.topAnchor),
            updatingStateContainerView.bottomAnchor.constraint(equalTo:self.bottomAnchor)
            ])
        self.updatePendingStateContainerView.isHidden = false
    }
    
}


extension TFLUpdateStatusView : TFLTimerViewDelegate {
    func tflTimerViewDidExpire(_ timerView : TFLTimerView) {
        self.delegate?.didExpireTimerInStatusView(self)
    }
}
