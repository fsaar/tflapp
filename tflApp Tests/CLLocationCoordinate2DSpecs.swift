import Quick
import Nimble
import CoreLocation
import UIKit

@testable import London_Bus
class CLLocationCoordinate2DSpecs : QuickSpec {
    
    override func spec() {
        
        var coordinates : [CLLocationCoordinate2D] = []
        var coordinates2 : [CLLocationCoordinate2D] = []

        beforeEach {
            let data = self.dataWithJSONFile("LoopRoute")
            let coordinateList = try! JSONDecoder().decode([[String:Double]].self, from: data)
            coordinates = coordinateList.map { CLLocationCoordinate2D(latitude: $0["latitude"]!, longitude: $0["longitude"]!) }

            let data2 = self.dataWithJSONFile("LoopRoute2")
            let coordinateList2 = try! JSONDecoder().decode([[String:Double]].self, from: data2)
            coordinates2 = coordinateList2.map { CLLocationCoordinate2D(latitude: $0["latitude"]!, longitude: $0["longitude"]!) }
        }
        
        context("when removeing loops") {
            it("should do that correctly") {
                expect(coordinates.loopRanges.isEmpty) == false
            }
            
            it("should return the ranges without overlaps") {
                expect {
                    _ = coordinates2.removeLoops()
                    }.notTo(raiseException())
            }
            
            it("should remove loops correctly") {
                let coords = coordinates.removeLoops()
                expect(coords.loopRanges.isEmpty) == true
            }
        }
    }
}

