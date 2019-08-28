import Foundation
import Nimble
import UIKit
import Quick

@testable import BusStops

class TFLNotificationObserverSpec: QuickSpec {
    
    override func spec() {
        var notificationName : Notification.Name!
        beforeEach {
            notificationName =  Notification.Name("TestNotification")
        }
        
        describe("When instantiating notification handler") {
            it ("should not be nil") {
                
                let handler = TFLNotificationObserver(notification:notificationName) { _ in }
                expect(handler).notTo(beNil())
            }

            it ("should call notificationHandler if enabled") {
                var called = false
                let handler = TFLNotificationObserver(notification:notificationName) { _ in
                    called = true
                }
                handler.enabled = true
                NotificationCenter.default.post(name: notificationName , object: nil)
                expect(called) == true
            }
            
            it ("should NOT call notificationHandler if NOT enabled") {
                var called = false
                let handler = TFLNotificationObserver(notification:notificationName) {  _ in
                    
                    called = true
                }
                
                handler.enabled = false
                NotificationCenter.default.post(name: notificationName, object: nil)
                expect(called) == false
            }
        }
        
    }
}
