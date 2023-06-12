//
//  TFLBusArrivalReminder.swift
//  tflapp
//
//  Created by Frank Saar on 09/12/2019.
//  Copyright © 2019 SAMedialabs. All rights reserved.
//

import UIKit

class TFLBusArrivalReminder {
    enum ReminderError : Error {
        case busArrivalPending
        case canceled
    }
    enum NotificationUserInfoKey : String {
        case minutesBeforeArrival = "NotificationUserInfoKeyMinutesBeforeArrival"
        case predictionIdentifier = "NotificationUserInfoKeyPredictionIdentifier"
        case stationIdentifier = "NotificationUserInfoKeyStationIdentifier"
        case lineIdentifier = "NotificationUserInfoKeyLineIdentifier"
        case stationName = "NotificationUserInfoKeyStationName"
    }
    fileprivate weak var contentViewController : UIViewController?
    fileprivate let notificationCenter = UNUserNotificationCenter.current()
    fileprivate weak var alertController : UIAlertController?
    fileprivate var backgroundNotificationHandler  : TFLNotificationObserver?
    
    init(with contentViewController : UIViewController) {
        self.contentViewController = contentViewController
        self.backgroundNotificationHandler = TFLNotificationObserver(notification:UIApplication.didEnterBackgroundNotification) { [weak self]  _ in
            guard self?.alertController === self?.contentViewController?.presentedViewController else {
                return
            }
            self?.contentViewController?.dismiss(animated: false, completion: nil)
        }
    }
    
    func showReminderForLine(line : String,arrivingIn seconds : Int,at station : String,with stationIdentifier : String,and predictionIdentifier : String, using completionBlock: ((_ success : Bool,_ error : Error?) -> Void)? = nil) {
        guard seconds > 60 else {
            completionBlock?(false,ReminderError.busArrivalPending)
            return
        }
        let sheet = achtionSheet(for: line, arrivingIn: seconds, at: station, with: stationIdentifier,and:predictionIdentifier,using: completionBlock)
        OperationQueue.main.addOperation{
            self.alertController = sheet
            self.contentViewController?.present(sheet, animated: true)
        }
    }
}

//
// MARK: - Helper
//
fileprivate extension TFLBusArrivalReminder {
    func achtionSheet(for line : String,arrivingIn seconds : Int,at station : String,with stationIdentifier : String,and predictionIdentifier : String,using completionBlock: ((_ success : Bool,_ error : Error?) -> Void)? = nil) -> UIAlertController {
        let isDarkMode = contentViewController?.view.traitCollection.userInterfaceStyle == .dark
        
        let reminderCopy = NSLocalizedString("TFLNearbyBusStationsController.notification.body",comment: "")
        let reminderMessage = String(format:reminderCopy,line,station)
        
        let title = NSLocalizedString("TFLNearbyBusStationsController.reminder.title",comment:"")
        let messageCopy = NSLocalizedString("TFLNearbyBusStationsController.reminder.message",comment:"")
        let message = String(format: messageCopy, line,station)
        let actionSheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        actionSheet.view.tintColor = isDarkMode ? .white : .red
        let dismissAction = UIAlertAction(title: NSLocalizedString("Common.dismiss",comment:""),style: .cancel) {  _ in
            completionBlock?(false,ReminderError.canceled)
        }
        actionSheet.addAction(dismissAction)
        let options = reminderOptionsWithArrivalTime(seconds)
        let actions : [UIAlertAction]  = options.map{ option in
            UIAlertAction(title: option.copy,style: .default) { [weak self] _ in
                let userInfo : [String:Any] = [NotificationUserInfoKey.minutesBeforeArrival.rawValue : option.minutesBeforeArrival,
                                               NotificationUserInfoKey.predictionIdentifier.rawValue: predictionIdentifier,
                                               NotificationUserInfoKey.stationIdentifier.rawValue: stationIdentifier,
                                               NotificationUserInfoKey.stationName.rawValue: station,
                                               NotificationUserInfoKey.lineIdentifier.rawValue: line]
                self?.createNotification(with: reminderMessage,userInfo: userInfo, in: option.timeInSeconds,with: predictionIdentifier, using:completionBlock)
            }
        }
        actions.forEach { action in
            actionSheet.addAction(action)
        }
        return actionSheet
    }
    
    func reminderOptionsWithArrivalTime(_ arrivalTimeInSeconds : Int) -> [(copy:String,timeInSeconds:Int,minutesBeforeArrival:Int )] {
        let minuteCopy = NSLocalizedString("Common.minute",comment: "")
        let minutesCopy = NSLocalizedString("Common.minutes",comment: "")
        let minuteTuple = ("1 \(minuteCopy)",60,1)
        
        let arrivalTimeInMinutes = arrivalTimeInSeconds / 60
        
        guard arrivalTimeInMinutes > 2 else {
            return ([minuteTuple])
        }
        var minutesBeforeDeparture : [Int] = []
        switch arrivalTimeInMinutes {
        case 3,4:
            minutesBeforeDeparture = [1,2]
        case 6...9:
            minutesBeforeDeparture = [2,3]
        default:
            minutesBeforeDeparture = [2,3,5]
        }
        let options : [(copy:String,timeInSeconds:Int,minutesBeforeArrival:Int)]  = minutesBeforeDeparture.map{ minutes in
            let expiryInMinutes = arrivalTimeInMinutes-minutes
            return
                ("\(minutes) \(minutesCopy)",expiryInMinutes * 60,minutes)
        }
        return options
    }
    
    func createNotification(with message : String,userInfo : [String:Any], in seconds : Int,with identifier : String,using completionBlock: ((_ success : Bool,_ error : Error?) -> Void)? = nil) {
        notificationCenter.requestAuthorization(options: [.badge,.sound,.alert]) { granted,_ in
            guard granted else {
                return
            }
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds), repeats: false)
            let content = UNMutableNotificationContent()
            content.title = NSLocalizedString("TFLNearbyBusStationsController.notification.title",comment: "")
            content.body = message
            content.sound = .default
            content.userInfo = userInfo
                        
            let request = UNNotificationRequest(identifier: identifier,
                                                content: content, trigger: trigger)
            self.notificationCenter.add(request) { error  in
                let success = error == nil ? true : false
                completionBlock?(success,error)
            }
        }
    }
}
