//
//  TFLErrorContainerVIew.swift
//  tflapp
//
//  Created by Frank Saar on 07/08/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//

import Foundation
import UIKit
// TODO: 1. definte proper delegate
// TODO: 2. definite accessiblity label for nogps error
// TODO: 3. check if switch statement in rootviewcontroller can be moved over via evaluation of error here

protocol TFLErrorContainerViewDelegate : AnyObject {
    func didTapNoGPSEnabledButton()
    func didTapNoStationsButton()
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
        errorView.setTitle(title, description: description, buttonCaption: buttonCaption, accessibilityLabel: "") { [weak self] _ in
            self?.delegate?.didTapNoGPSEnabledButton()
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
        errorView.setTitle(title, description: description, buttonCaption: buttonCaption, accessibilityLabel: accessibilityTitle) { [weak self] _ in
            self?.delegate?.didTapNoStationsButton()
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
