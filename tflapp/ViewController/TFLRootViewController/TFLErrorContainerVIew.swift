//
//  TFLErrorContainerVIew.swift
//  tflapp
//
//  Created by Frank Saar on 07/08/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//

import Foundation
import UIKit

protocol TFLErrorContainerViewDelegate : TFLNoStationsViewDelegate,TFLNoGPSEnabledViewDelegate {
    
}

class TFLErrorContainerView : UIView {
    weak var delegate : TFLErrorContainerViewDelegate?
    
    @IBOutlet weak var noGPSEnabledView : TFLNoGPSEnabledView! = nil {
        didSet {
            self.noGPSEnabledView.delegate = self
        }
    }
    @IBOutlet weak var loadArrivalTimesView : TFLLoadArrivalTimesView!
    @IBOutlet weak var noStationsView : TFLNoStationsView! = nil {
        didSet {
            self.noStationsView.delegate = self
        }
    }
    @IBOutlet weak var loadLocationsView : TFLLoadLocationView!
    @IBOutlet weak var loadNearbyStationsView : TFLLoadNearbyStationsView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        hideErrorViews()
    }
    
    func hideErrorViews() {
        self.noGPSEnabledView.isHidden = true
        self.loadArrivalTimesView.isHidden = true
        self.noStationsView.isHidden = true
        self.loadLocationsView.isHidden = true
        self.loadNearbyStationsView.isHidden = true
    }
    
    func showNoGPSEnabledError() {
        hideErrorViews()
        noGPSEnabledView.isHidden = false
    }
    
    func showNoStationsFoundError() {
        hideErrorViews()
        noStationsView.isHidden = false
    }
    
    func showLoadingArrivalTimesIfNeedBe(isContentAvailable : Bool) {
        hideErrorViews()
        loadArrivalTimesView.isHidden = isContentAvailable
    }
    
    func showLoadingCurrentLocationIfNeedBe(isContentAvailable : Bool) {
        hideErrorViews()
        loadLocationsView.isHidden = isContentAvailable
    }
    
    func showLoadingNearbyStationsIfNeedBe(isContentAvailable : Bool) {
        hideErrorViews()
        loadNearbyStationsView.isHidden = isContentAvailable
    }

    
    
}

extension TFLErrorContainerView : TFLNoStationsViewDelegate {
    func didTap(noStationsButton: UIButton,in view : TFLNoStationsView) {
        self.delegate?.didTap(noStationsButton: noStationsButton, in: view)
    }
}

extension TFLErrorContainerView : TFLNoGPSEnabledViewDelegate {
    func didTap(noGPSEnabledButton: UIButton,in view : TFLNoGPSEnabledView) {
        self.delegate?.didTap(noGPSEnabledButton: noGPSEnabledButton, in: view)
    }
}
