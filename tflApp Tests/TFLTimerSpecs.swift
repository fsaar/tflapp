import Quick
import Nimble
import CoreLocation
import UIKit

@testable import London_Bus
class TFLTimerSpec: QuickSpec {
    
    override func spec() {
        
        describe("when instantiating class") {
            it ("should not be nil with a sound updateTimer and timerHandler") {
                let timer = TFLTimer(timerInterVal: 0.25, timerHandler: { _ in
                })
                expect(timer).toNot(beNil())
            }
            
            it ("should be nil if update Time is zero") {
                let timer = TFLTimer(timerInterVal: 0.0, timerHandler: { _ in
                })
                expect(timer).to(beNil())
                
            }
            
            it ("should be nil if update Time is negative") {
                let timer = TFLTimer(timerInterVal: -1.0, timerHandler: { timer in
                })
                expect(timer).to(beNil())
                
            }
            
            it ("should be nil if timer handler block is nil") {
                let timer = TFLTimer(timerInterVal: 1.0, timerHandler: nil)
                expect(timer).to(beNil())
                
            }
        }
        
        describe("when starting timer") {
            it ("should call timerhandler if timer times out") {
                var called  = false
                let timer = TFLTimer(timerInterVal: 0.01) { _ in
                    called = true
                }
                timer?.start()
                expect(called).toEventually(beTrue(),timeout:1)
                
            }
            it ("should NOT call timerhandler if timer stopped before timing out") {
                var called  = false
                let timer = TFLTimer(timerInterVal: 0.01, timerHandler: { _ in
                    called = true
                })
                timer?.start()
                timer?.stop()
                expect(called).toEventually(beFalse())
                
            }
        }
        
        describe("when checking hasStarted flag") {
            var timer : TFLTimer!
            beforeEach {
                timer = TFLTimer(timerInterVal: 0.25, timerHandler: { _ in
                })
            }
            it ("should return true if timer has started") {
                timer?.start()
                expect(timer?.hasStarted) == true
            }
            
            it ("should return false if timer has stopped") {
                timer?.start()
                timer?.stop()
                expect(timer?.hasStarted) == false
                
            }
            
            it ("should return false if timer has only been initialized") {
                expect(timer?.hasStarted) == false
               
            }
       }

    }
}

