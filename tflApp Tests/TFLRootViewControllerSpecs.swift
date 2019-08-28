    
import Quick
import Nimble
import CoreLocation
import UIKit

@testable import BusStops

        
    
class TFLRootViewControllerSpecs: QuickSpec {
    
    override func spec() {
        var controller : TFLRootViewController!
        beforeEach() {
           let storyboard = UIStoryboard(name: "Main", bundle: nil)
            controller = storyboard.instantiateViewController(withIdentifier: String(describing:TFLRootViewController.self)) as? TFLRootViewController
        }

        it("should NOT be nil") {
            expect(controller).notTo(beNil())
        }
    }
}
