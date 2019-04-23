import Quick
import Nimble
import UIKit

@testable import London_Bus
class StringSpecs: QuickSpec {
    
    override func spec() {
        
       
        fit("should calculate the right SHA") {
            TFLHUD.show()
            let sha = "Test".sha256()
            expect(sha) == "Uy6qvZV0iA2/drm4zACDLCCm7BE9aCKZVQ16bg80XiU="
        }
        
        fit("should calculate the right SHA with a different string") {
            TFLHUD.show()
            let sha = "TFLApp".sha256()
            expect(sha) == "6bXjBYFAczUtj+Siqt81eS79MCQW4VDVMgQWLX1oXqo="
        }
        
        
        
        
    }
            
}

