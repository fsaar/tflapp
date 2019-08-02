//
//  TFLErrorContainerVIew.swift
//  tflapp
//
//  Created by Frank Saar on 07/08/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//

import Foundation
import UIKit
// TODO: 3. check if switch statement in rootviewcontroller can be moved over via evaluation of error here

protocol TFLErrorContainerViewDelegate : AnyObject {
    func errorContainerViewDidTapNoGPSEnabledButton(_ containerView : UIView,button : UIButton)
    func errorContainerViewDidTapNoStationsButton(_ containerView : UIView,button : UIButton)
}

class TFLErrorContainerView : UIView {
    weak var delegate : TFLErrorContainerViewDelegate?
    var errorViews : [UIView] = []
    @IBOutlet weak var errorView : TFLErrorView!
    @IBOutlet weak var progressInformationView : TFLProgressInformationView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        errorViews = [errorView,progressInformationView]
        hideErrorViews()
        updateColors()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle else {
            return
        }
        updateColors()
    }
    
    func hideErrorViews() {
        self.isHidden = true
        self.errorViews.forEach { $0.isHidden = true }
    }
    
    func showNoGPSEnabledError() {
        hideErrorViews()
        let description = NSLocalizedString("TFLNoGPSEnabledView.title", comment: "")
        let title = NSLocalizedString("TFLNoGPSEnabledView.headerTitle", comment: "")
        let buttonCaption = NSLocalizedString("TFLNoGPSEnabledView.settingsButtonTitle", comment: "")
        let accessibilityTitle = NSLocalizedString("TFLNoGPSEnabledView.accessibilityTitle",comment:"")
        
        errorView.setTitle(title, description: description, buttonCaption: buttonCaption, accessibilityLabel: accessibilityTitle) { [weak self] button in
            guard let self = self else {
                return
            }
            self.delegate?.errorContainerViewDidTapNoGPSEnabledButton(self.errorView, button: button)
        }
        errorView.isHidden = false
        self.isHidden = false
    }
    
    func showNoStationsFoundError() {
        hideErrorViews()
        
        let title = NSLocalizedString("TFLNoStationsView.title", comment: "")
        let description  = NSLocalizedString("TFLNoStationsView.description", comment: "")
        let buttonCaption = NSLocalizedString("TFLNoStationsView.retryButtonTitle", comment: "")
        let accessibilityTitle = NSLocalizedString("TFLNoStationsView.accessibilityTitle",comment:"")
        errorView.setTitle(title, description: description, buttonCaption: buttonCaption, accessibilityLabel: accessibilityTitle) { [weak self] button in
            guard let self = self else {
                return
            }
            self.delegate?.errorContainerViewDidTapNoStationsButton(self.errorView,button:button)
        }
        errorView.isHidden = false
        self.isHidden = false
    }
    
    func showLoadingArrivalTimesIfNeedBe(isContentAvailable : Bool) {
        hideErrorViews()
        let accessiblityTitle = NSLocalizedString("TFLLoadArrivalTimesView.accessiblityTitle",comment:"")
        let title = NSLocalizedString("TFLLoadArrivalTimesView.title", comment: "")
        progressInformationView.setInformation(title, accessibilityLabel: accessiblityTitle)
        progressInformationView.isHidden = isContentAvailable
        self.isHidden = isContentAvailable
    }
    
    func showLoadingCurrentLocationIfNeedBe(isContentAvailable : Bool) {
        hideErrorViews()
        let accessiblityTitle = NSLocalizedString("TFLLoadLocationView.accessibilityTitle",comment:"")
        let title = NSLocalizedString("TFLLoadLocationView.title", comment: "")
        progressInformationView.setInformation(title, accessibilityLabel: accessiblityTitle)
        progressInformationView.isHidden = isContentAvailable
        self.isHidden = isContentAvailable
    }
    
    func showLoadingNearbyStationsIfNeedBe(isContentAvailable : Bool) {
        hideErrorViews()
        let accessiblityTitle = NSLocalizedString("TFLLoadNearbyStationsView.accessibilityTitle",comment:"")
        let title = NSLocalizedString("TFLLoadNearbyStationsView.title", comment: "")
        progressInformationView.setInformation(title, accessibilityLabel: accessiblityTitle)
        progressInformationView.isHidden = isContentAvailable
        self.isHidden = isContentAvailable
    }
}


fileprivate extension TFLErrorContainerView {
    func updateColors() {
        self.backgroundColor = UIColor(named: "tflBackgroundColor")
    }
}
