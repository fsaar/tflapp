//
//  TFLBusArrivalReminder.swift
//  tflapp
//
//  Created by Frank Saar on 09/12/2019.
//  Copyright © 2019 SAMedialabs. All rights reserved.
//

import UIKit

protocol TFLBusArrivalReminderDelegate : AnyObject {
    func tflBusArrivalReminderDidCreateNotification(_ reminder : TFLBusArrivalReminder)
}

class TFLBusArrivalReminder {
    weak var delegate : TFLBusArrivalReminderDelegate?
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
    
    func showReminderForLine(line : String,arrivingIn seconds : Int,at station : String) {
        guard seconds > 60 else {
            return
        }
        let sheet = achtionSheet(for: line, arrivingIn: seconds, at: station)
        OperationQueue.main.addOperation {
            self.alertController = sheet
            self.contentViewController?.present(sheet, animated: true)
        }
    }
}

//
// MARK: - Helper
//
fileprivate extension TFLBusArrivalReminder {
    func achtionSheet(for line : String,arrivingIn seconds : Int,at station : String) -> UIAlertController {
        let isDarkMode = contentViewController?.view.traitCollection.userInterfaceStyle == .dark
        
        let reminderCopy = NSLocalizedString("TFLNearbyBusStationsController.notification.body",comment: "")
        let reminderMessage = String(format:reminderCopy,line,station)
        
        let title = NSLocalizedString("TFLNearbyBusStationsController.reminder.title",comment:"")
        let messageCopy = NSLocalizedString("TFLNearbyBusStationsController.reminder.message",comment:"")
        let message = String(format: messageCopy, line,station)
        let actionSheet = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
        actionSheet.view.tintColor = isDarkMode ? .white : .red
        let dismissAction = UIAlertAction(title: NSLocalizedString("Common.dismiss",comment:""),style: .cancel,handler:nil)
        actionSheet.addAction(dismissAction)
        let options = reminderOptionsWithArrivalTime(seconds)
        let actions : [UIAlertAction]  = options.map { option in
            UIAlertAction(title: option.copy,style: .default) { [weak self] _ in
                self?.createNotification(with: reminderMessage, in: option.timeInSeconds)
            }
        }
        actions.forEach { action in
            actionSheet.addAction(action)
        }
        return actionSheet
    }
    
    func reminderOptionsWithArrivalTime(_ arrivalTimeInSeconds : Int) -> [(copy:String,timeInSeconds:Int)] {
        let minuteCopy = NSLocalizedString("Common.minute",comment: "")
        let minutesCopy = NSLocalizedString("Common.minutes",comment: "")
        let minuteTuple = ("1 \(minuteCopy)",60)
        
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
        let options : [(copy:String,timeInSeconds:Int)]  = minutesBeforeDeparture.map { minutes in
            let expiryInMinutes = arrivalTimeInMinutes-minutes
            return
                ("\(minutes) \(minutesCopy)",expiryInMinutes * 60)
        }
        return options
    }
    
    func createNotification(with message : String,in seconds : Int) {
        notificationCenter.requestAuthorization(options: [.badge,.sound,.alert]) { granted,_ in
            guard granted else {
                return
            }
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(seconds), repeats: false)
            let content = UNMutableNotificationContent()
            content.title = NSLocalizedString("TFLNearbyBusStationsController.notification.title",comment: "")
            content.body = message
            content.sound = .default
            
            let request = UNNotificationRequest(identifier: "tflapp.reminder",
                                                content: content, trigger: trigger)
            self.notificationCenter.add(request) { [weak self] error  in
                guard let self = self,case .none = error else {
                    return
                }
                self.delegate?.tflBusArrivalReminderDidCreateNotification(self)
            }
        }
    }
}
