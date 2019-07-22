//
//  TFLSplashscreencontroller.swift
//  tflapp
//
//  Created by Frank Saar on 12/02/2019.
//  Copyright © 2019 SAMedialabs. All rights reserved.
//

import Foundation
import UIKit

class TFLSplashscreenController : UIViewController {
    
    @IBOutlet weak var titlePart1 : UILabel!
    @IBOutlet weak var titlePart2 : UILabel!
    @IBOutlet weak var imageView : UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateColors()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle else {
            return
        }
        updateColors()
    }
    
}

// MARK: - Private

extension TFLSplashscreenController {
    func updateColors() {
        self.view.backgroundColor = UIColor(named: "tflSplashScreenBackgroundColor")
        self.titlePart1.textColor = UIColor(named: "tflSplashScreenTextColor")
        self.titlePart2.textColor = UIColor(named: "tflSplashScreenTextColor")
        self.imageView.tintColor = UIColor(named: "tflSplashScreenTextColor")
    }
}
