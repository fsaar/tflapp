//
//  TFLErrorContainerVIew.swift
//  tflapp
//
//  Created by Frank Saar on 07/08/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//

import Foundation
import UIKit

protocol TFLErrorContainerViewDelegate : AnyObject {
    func errorContainerViewDidTapNoGPSEnabledButton(_ containerView : UIView,button : UIButton)
    func errorContainerViewDidTapNoStationsButton(_ containerView : UIView,button : UIButton)
}

class TFLErrorContainerView : UIView {
    enum ErrorView {
        case noGPSAvailable
        case noStationsNearby
        case determineCurrentLocation
        case loadingNearbyStations
        case loadingArrivals
        
        var errorTuple : (title : String,descripion : String?, buttonCaption : String?,accessibilityTitle : String) {
            switch self {
            case .noGPSAvailable:
                let description = NSLocalizedString("TFLNoGPSEnabledView.title", comment: "")
                let title = NSLocalizedString("TFLNoGPSEnabledView.headerTitle", comment: "")
                let buttonCaption = NSLocalizedString("TFLNoGPSEnabledView.settingsButtonTitle", comment: "")
                let accessibilityTitle = NSLocalizedString("TFLNoGPSEnabledView.accessibilityTitle",comment:"")
                return (title,description,buttonCaption,accessibilityTitle)
            case .noStationsNearby:
                let title = NSLocalizedString("TFLNoStationsView.title", comment: "")
                let description  = NSLocalizedString("TFLNoStationsView.description", comment: "")
                let buttonCaption = NSLocalizedString("TFLNoStationsView.retryButtonTitle", comment: "")
                let accessibilityTitle = NSLocalizedString("TFLNoStationsView.accessibilityTitle",comment:"")
                return (title,description,buttonCaption,accessibilityTitle)
            case .determineCurrentLocation:
                let accessibilityTitle = NSLocalizedString("TFLLoadNearbyStationsView.accessibilityTitle",comment:"")
                let title = NSLocalizedString("TFLLoadNearbyStationsView.title", comment: "")
                return (title,nil,nil,accessibilityTitle)
            case .loadingNearbyStations:
                let accessibilityTitle = NSLocalizedString("TFLLoadLocationView.accessibilityTitle",comment:"")
                let title = NSLocalizedString("TFLLoadLocationView.title", comment: "")
                return (title,nil,nil,accessibilityTitle)
            case .loadingArrivals:
                let accessibilityTitle = NSLocalizedString("TFLLoadArrivalTimesView.accessiblityTitle",comment:"")
                let title = NSLocalizedString("TFLLoadArrivalTimesView.title", comment: "")
                return (title,nil,nil,accessibilityTitle)
            }
        }
        func delegateMethod(_ delegate : TFLErrorContainerViewDelegate?) -> ((UIView,UIButton) -> Void)? {
            switch self {
            case .noGPSAvailable:
                return delegate?.errorContainerViewDidTapNoGPSEnabledButton(_:button:)
            case .noStationsNearby:
                return delegate?.errorContainerViewDidTapNoStationsButton(_:button:)
            default:
                return nil
            }
        }
    }
      
    weak var delegate : TFLErrorContainerViewDelegate?
    fileprivate var errorViews : [UIView] = []
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
    
    func showErrorView(_ errorView : ErrorView) {
        hideErrorViews()
        self.isHidden = false
        switch errorView {
        case .noGPSAvailable,.noStationsNearby:
            showErrorView(view: errorView)
        case .loadingArrivals,.loadingNearbyStations,.determineCurrentLocation:
            configureProgressInformationView(view: errorView)
        }
    }
    
    func hideErrorViews() {
        self.isHidden = true
        self.errorViews.forEach { $0.isHidden = true }
    }
}

// MARK: - Private

fileprivate extension TFLErrorContainerView {
    func showErrorView(view : ErrorView) {
        let (title,desc, caption,accessibilityTitle) = view.errorTuple
        
        errorView.setTitle(title, description: desc, buttonCaption: caption, accessibilityLabel: accessibilityTitle) { [weak self] button in
            guard let self = self else {
                return
            }
            let delegateCall = view.delegateMethod(self.delegate)
            delegateCall?(self.errorView, button)
        }
        errorView.isHidden = false
    }
    
    func configureProgressInformationView(view : ErrorView) {
        let (title,_, _,accessibilityTitle) = view.errorTuple
        progressInformationView.setInformation(title, accessibilityLabel: accessibilityTitle)
        progressInformationView.isHidden = false
    }
    
    func updateColors() {
        self.backgroundColor = UIColor(named: "tflBackgroundColor")
    }
}
