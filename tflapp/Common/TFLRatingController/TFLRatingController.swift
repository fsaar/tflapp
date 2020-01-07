//
//  TFLRatingController.swift
//  tflapp
//
//  Created by Frank Saar on 07/01/2020.
//  Copyright © 2020 SAMedialabs. All rights reserved.
//

import UIKit
import Combine
import StoreKit

class TFLRatingController {
    @Settings(key: .appForegroundCounter,defaultValue: 0) fileprivate var foregroundCounter : Int
    
    var foregroundNotificationHandler : AnyCancellable? = nil
    
    init() {
        foregroundNotificationHandler =  NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification).sink { [foregroundHandler] _ in
            foregroundHandler()
        }
    }
}

//
// MARK: - Helper
//
fileprivate extension TFLRatingController {
    func foregroundHandler() {
        foregroundCounter += 1
        evaluateRatingDialog()
    }
    
    func evaluateRatingDialog() {
        switch foregroundCounter {
        case 100,1000:
            SKStoreReviewController.requestReview()
        default:
            guard foregroundCounter % 1000 == 0 else  {
                return
            }
            SKStoreReviewController.requestReview()
        }
    }
}
