import Quick
import Nimble
import CoreLocation
import UIKit

@testable import BusStops
class TFLHUDSpecs: QuickSpec {
    
    override func spec() {
        
        context("when showing TFLHUD") {
            it("should add visualeffectsView to window") {
                TFLHUD.show()
                let delegate  = UIApplication.shared.delegate as! AppDelegate
                let window  = delegate.window
                let views = window?.subviews.filter { $0 is UIVisualEffectView }
                expect(views!.count) == 1
            }
        }
        
        context("when hiding TFLHUD") {
            it("should remove visualeffectsView to window") {
                TFLHUD.show()
                TFLHUD.hide()
                let delegate  = UIApplication.shared.delegate as! AppDelegate
                let window  = delegate.window
                let views = window?.subviews.filter { $0 is UIVisualEffectView }
                expect(views!.count) == 0
            }
        }
        
    }
            
}

