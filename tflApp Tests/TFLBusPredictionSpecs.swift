
import Quick
import Nimble
import CoreData

@testable import London_Bus

class TFLBusPredictionSpecs: QuickSpec {
    
    override func spec() {
        var dict : [String : Any]!
        
        beforeEach() {
            dict = [
                "id": "1836802865",
                "vehicleId": "LTZ1218",
                "naptanId": "490011791K",
                "lineId": "38",
                "lineName": "38",
                "destinationName": "Victoria",
                "timestamp": "2016-11-16T15:59:35Z",
                "timeToStation": UInt(902),
                "timeToLive": "2016-11-16T16:15:07Z"]
        }
        
        it ("should instantiate model with valid dicationary") {
            let model = TFLBusPrediction(with:dict)
            expect(model).notTo(beNil())
        }
        
        it ("should not instantiate model if identifier is missing") {
            var newDict = dict
            newDict!["id"] = nil
            let model = TFLBusPrediction(with:newDict!)
            expect(model).to(beNil())
        }
        
        it ("should instantiate model correctly") {
            let model = TFLBusPrediction(with:dict)
            expect(model!.identifier) == "1836802865"
            expect(model!.ttlSinceReferenceDate) > 0
            expect(model!.busStopIdentifier) == "490011791K"
            expect(model!.timeStampSinceReferenceDate) > 0
            expect(model!.lineIdentifier) == "38"
            expect(model!.lineName) == "38"
            expect(model!.destination) == "Victoria"
            expect(model!.timeToStation) == 902
        }
    }
}
