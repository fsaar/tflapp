    
import Quick
import Nimble
import UIKit

@testable import London_Bus

class TFLAnimationLabelSpecs: QuickSpec {
    
    override func spec() {
        var label : TFLAnimiatedLabel!
        beforeEach() {
            label = TFLAnimiatedLabel(frame:CGRect(origin:.zero, size: CGSize(width: 100, height: 20)))
        }
        it("should not be nil") {
            expect(label).notTo(beNil())
        }
        
        it("should have 2 labels as subviews") {
            let labels = label.subviews.compactMap { $0 as? UILabel }
            expect(labels.count) == 2
        }
        
        context("when calling setText") {
            var label1 : UILabel!
            var label2 : UILabel!
            beforeEach() {
                let labels = label.subviews.compactMap { $0 as? UILabel }
                label1 = labels.first!
                label2 = labels.last!
            }
            it("should set labels text property to text") {
                label.setText("test", animated: true)
                expect(label.text) == "test"
            }
            
            it ("should set first label's title to given text if animated") {
               label.setText("test", animated: true)
                expect(label1.text) == "test"
            }
            
            it ("should eventually set last label's title to given text if animated ") {
                label.setText("test", animated: true)
                expect(label2.text).toEventually(equal("test"),timeout:2)
                
            }
            
            it("should set first label's title to given text if not animated") {
                UIView.performWithoutAnimation {
                    label.setText("test", animated: false)
                    expect(label2.text) == "test"
                }
            }
        }
    }
}
