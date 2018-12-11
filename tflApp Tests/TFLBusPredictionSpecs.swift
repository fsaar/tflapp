
import Quick
import Nimble
import CoreData

@testable import London_Bus

class TFLBusPredictionSpecs: QuickSpec {
    
    override func spec() {
        var jsonData : Data!
        var decoder : JSONDecoder!
        beforeEach() {
            decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            jsonData = """
            {
                "id": "1836802865",
                "towards" : "",
                "vehicleId": "LTZ1218",
                "naptanId": "490011791K",
                "lineId": "38",
                "lineName": "38",
                "destinationName": "Victoria",
                "timestamp": "2016-11-16T15:59:35.1741351Z",
                "timeToStation": 902,
                "timeToLive": "2016-11-16T16:15:07Z"
            }
            """.data(using: .utf8)
            
            
        }
        
        it ("should instantiate model with valid dicationary") {
            let model = try! decoder.decode(TFLBusPrediction.self, from: jsonData)
            expect(model).notTo(beNil())
        }
        
        it ("should not instantiate model if identifier is missing") {
            let invalidJSONData = """
            {
                "vehicleId": "LTZ1218",
                "naptanId": "490011791K",
                "lineId": "38",
                "lineName": "38",
                "destinationName": "Victoria",
                "timestamp": "2016-11-16T15:59:35.1741351Z",
                "timeToStation": 902,
                "timeToLive": "2016-11-16T16:15:07Z"
            }
            """.data(using: .utf8)!
            let model = try? decoder.decode(TFLBusPrediction.self, from: invalidJSONData)
            expect(model).to(beNil())
        }
        
        it ("should instantiate model correctly") {
            let model = try? decoder.decode(TFLBusPrediction.self, from: jsonData)
            expect(model!.identifier) == "1836802865"
            expect(model!.timeToLive).notTo(beNil())
            expect(model!.busStopIdentifier) == "490011791K"
            expect(model!.timeStamp).notTo(beNil())
            expect(model!.lineIdentifier) == "38"
            expect(model!.lineName) == "38"
            expect(model!.destination) == "Victoria"
            expect(model!.timeToStation) == 902
        }
    }
}
