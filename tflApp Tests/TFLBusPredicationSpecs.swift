
import Quick
import Nimble
import CoreData

@testable import London_Bus

class TFLBusPredicationSpecs: QuickSpec {
    
    override func spec() {
        var dict : [String : Any]!
        
        beforeEach() {
            dict = [
                "$type" : "Tfl.Api.Presentation.Entities.Prediction, Tfl.Api.Presentation.Entities",
                "id": "1836802865",
                "operationType": 1,
                "vehicleId": "LTZ1218",
                "naptanId": "490011791K",
                "stationName": "Trocadero / Haymarket",
                "lineId": "38",
                "lineName": "38",
                "platformName": "K",
                "direction": "outbound",
                "bearing": "215",
                "destinationNaptanId": "",
                "destinationName": "Victoria",
                "timestamp": "2016-11-16T15:59:35Z",
                "timeToStation": UInt(902),
                "currentLocation": "",
                "towards": "Hyde Park Corner",
                "expectedArrival": "2016-11-16T16:14:37.51239Z",
                "timeToLive": "2016-11-16T16:15:07.51239Z",
                "modeName": "bus",
                "timing": [
                    "$type": "Tfl.Api.Presentation.Entities.PredictionTiming, Tfl.Api.Presentation.Entities",
                    "countdownServerAdjustment": "00:00:00.2085048",
                    "source": "2016-11-15T10:29:13.742Z",
                    "insert": "2016-11-16T15:59:10.857Z",
                    "read": "2016-11-16T15:59:10.857Z",
                    "sent": "2016-11-16T15:59:35Z",
                    "received": "0001-01-01T00:00:00Z"
                ]]
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
            expect(model!.ttl) == "2016-11-16T16:15:07.51239Z"
            expect(model!.busStopIdentifier) == "490011791K"
            expect(model!.timeStamp) == "2016-11-16T15:59:35Z"
            expect(model!.lineIdentifier) == "38"
            expect(model!.lineName) == "38"
            expect(model!.destination) == "Victoria"
            expect(model!.timeToStation) == 902
        }
    }
}
