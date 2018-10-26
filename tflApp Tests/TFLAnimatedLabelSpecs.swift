import Quick
import Nimble
import CoreLocation
import UIKit

@testable import London_Bus
class TFLAnimatedLabelSpecs: QuickSpec {
    
    override func spec() {
        
        it ("can be instantiated") {
            let animatedLabel = TFLAnimatedLabel(frame: .zero)
            expect(animatedLabel).notTo(beNil())
        }
        
        it ("can set text without animation") {
            let animatedLabel = TFLAnimatedLabel(frame: .zero)
            animatedLabel.setText("Hello world")
            expect(animatedLabel.text) == "Hello world"

        }
        
        it ("should propagate text to underlying labels") {
            let animatedLabel = TFLAnimatedLabel(frame: .zero)
            animatedLabel.setText("Hello world")
            let label1 = animatedLabel.subviews.filter ({ $0 is UILabel })[0] as? UILabel
            let label2 = animatedLabel.subviews.filter ({ $0 is UILabel })[1] as? UILabel
            expect(label1!.text) == "Hello world"
            expect(label2!.text) == "Hello world"
        }
        
        it ("should propagate background color to underlying labels") {
            let animatedLabel = TFLAnimatedLabel(frame: .zero)
            animatedLabel.backgroundColor = UIColor .green
            let label1 = animatedLabel.subviews.filter ({ $0 is UILabel })[0] as? UILabel
            let label2 = animatedLabel.subviews.filter ({ $0 is UILabel })[1] as? UILabel
            expect(label1!.backgroundColor) == UIColor.green
            expect(label2!.backgroundColor) == UIColor.green
        }
        
        it ("should propagate alignment to underlying labels") {
            let animatedLabel = TFLAnimatedLabel(frame: .zero)
            animatedLabel.textAlignment = NSTextAlignment.justified
            let label1 = animatedLabel.subviews.filter ({ $0 is UILabel })[0] as? UILabel
            let label2 = animatedLabel.subviews.filter ({ $0 is UILabel })[1] as? UILabel
            expect(label1!.textAlignment) == NSTextAlignment.justified
            expect(label2!.textAlignment) == NSTextAlignment.justified

        }
        
        it ("should propagate textcolor to underlying labels") {
            let animatedLabel = TFLAnimatedLabel(frame: .zero)
            animatedLabel.textColor = UIColor .red
            let label1 = animatedLabel.subviews.filter ({ $0 is UILabel })[0] as? UILabel
            let label2 = animatedLabel.subviews.filter ({ $0 is UILabel })[1] as? UILabel
            expect(label1!.textColor) == UIColor.red
            expect(label2!.textColor) == UIColor.red
        }
        
        it ("should propagate font to underlying labels") {
            let animatedLabel = TFLAnimatedLabel(frame: .zero)
            animatedLabel.font = UIFont.systemFont(ofSize: 44)
            let label1 = animatedLabel.subviews.filter ({ $0 is UILabel })[0] as? UILabel
            let label2 = animatedLabel.subviews.filter ({ $0 is UILabel })[1] as? UILabel
            expect(label1!.font) == UIFont.systemFont(ofSize: 44)
            expect(label2!.font) == UIFont.systemFont(ofSize: 44)

        }
        
        it ("can set text with animation") {
            let animatedLabel = TFLAnimatedLabel(frame: .zero)
            animatedLabel.setText("Hello world",animated: true)
            
            expect(animatedLabel.text) == "Hello world"
            
            let label1 = animatedLabel.subviews.filter ({ $0 is UILabel })[0] as? UILabel
            let label2 = animatedLabel.subviews.filter ({ $0 is UILabel })[1] as? UILabel
            expect(label1!.text).toEventually(equal("Hello world"),timeout:5)
            expect(label2!.text).toEventually(equal("Hello world"),timeout:5)
        }
        
    }
            
}

