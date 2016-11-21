import Foundation
import Nimble
import UIKit
import Quick

@testable import London_Bus

class TFLNotificationObserverSpec: QuickSpec {
    
    override func spec() {
        var notificationName : String!
        beforeEach {
            notificationName = "NMATestNotification"
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
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: notificationName) , object: nil)
                expect(called) == true
            }
            
            it ("should NOT call notificationHandler if NOT enabled") {
                var called = false
                let handler = TFLNotificationObserver(notification:notificationName) {  _ in
                    
                    called = true
                }
                
                handler.enabled = false
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: notificationName), object: nil)
                expect(called) == false
            }
        }
        
    }
}
