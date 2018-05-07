    
import Quick
import Nimble
import CoreLocation
import UIKit

@testable import London_Bus

        
    
class TFLRootViewControllerSpecs: QuickSpec {
    
    override func spec() {
        var controller : TFLRootViewController!
        beforeEach() {
           let storyboard = UIStoryboard(name: "Main", bundle: nil)
            controller = storyboard.instantiateViewController(withIdentifier: String(describing:TFLRootViewController.self)) as! TFLRootViewController
        }

        it("should NOT be nil") {
            expect(controller).notTo(beNil())
        }
        
        context("When testing refreshTimer") {
            it("should start timer in viewDidLoad") {
                _ = controller.view
                expect(controller.refreshTimer!.hasStarted) == true
            }
            
            it("should stop timer when going into background") {
                _ = controller.view
                NotificationCenter.default.post(name: .UIApplicationDidEnterBackground, object: nil)
                expect(controller.refreshTimer!.hasStarted) == false
            }
            
            it("should start timer when coming to foreground") {
                _ = controller.view
                NotificationCenter.default.post(name: .UIApplicationDidEnterBackground, object: nil)
                NotificationCenter.default.post(name: .UIApplicationWillEnterForeground, object: nil)
                expect(controller.refreshTimer!.hasStarted) == true
            }
            
        }
    }
}
