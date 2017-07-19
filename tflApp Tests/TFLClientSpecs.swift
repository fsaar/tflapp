    
import Quick
import Nimble
import CoreLocation
import UIKit

@testable import London_Bus

private class TestRequestManager : TFLRequestManager {
    
    var getDataCompletionBlock : ((_ relativePath: String)->(data : Data?,error:Error?))?
    override public func getDataWithRelativePath(relativePath: String ,and query: String? = nil, completionBlock:@escaping ((_ data : Data?,_ error:Error?) -> Void)) {
        if let (data,error) = getDataCompletionBlock?(relativePath) {
            completionBlock(data,error)
        }
        else
        {
            completionBlock(nil,TFLRequestManagerErrorType.InvalidURL(urlString: ""))
        }
        
    }
}
    
class TFLClientSpecs: QuickSpec {
    
    override func spec() {
        var client : TFLClient!
        var testRequestManager : TestRequestManager!
        var arrivalsTestData : Data!
        var nearbyBusStopsData : Data!
        beforeEach() {
            client = TFLClient()
            testRequestManager = TestRequestManager()
            client.tflManager = testRequestManager
            arrivalsTestData = """
                [{
                 "$type": "Tfl.Api.Presentation.Entities.Prediction, Tfl.Api.Presentation.Entities",
                 "id": "27797305",
                 "operationType": 1,
                 "vehicleId": "LTZ1418",
                 "naptanId": "490007960P",
                 "stationName": "Haymarket / Charles II Street",
                 "lineId": "12",
                 "lineName": "12",
                 "platformName": "P",
                 "direction": "outbound",
                 "bearing": "148",
                 "destinationNaptanId": "",
                 "destinationName": "Dulwich Library",
                 "timestamp": "2017-07-19T16:19:23Z",
                 "timeToStation": 1595,
                 "currentLocation": "",
                 "towards": "Parliament Square",
                 "expectedArrival": "2017-07-19T16:45:58Z",
                 "timeToLive": "2017-07-19T16:46:28Z",
                 "modeName": "bus",
                 "timing": {
                     "$type": "Tfl.Api.Presentation.Entities.PredictionTiming, Tfl.Api.Presentation.Entities",
                     "countdownServerAdjustment": "00:00:01.6749719",
                     "source": "2017-07-17T12:57:07.619Z",
                     "insert": "2017-07-19T16:18:43.812Z",
                     "read": "2017-07-19T16:18:43.812Z",
                     "sent": "2017-07-19T16:19:23Z",
                     "received": "0001-01-01T00:00:00Z"
                 }
             }, {
                 "$type": "Tfl.Api.Presentation.Entities.Prediction, Tfl.Api.Presentation.Entities",
                 "id": "-482299310",
                 "operationType": 1,
                 "vehicleId": "LTZ1419",
                 "naptanId": "490007960P",
                 "stationName": "Haymarket / Charles II Street",
                 "lineId": "12",
                 "lineName": "12",
                 "platformName": "P",
                 "direction": "outbound",
                 "bearing": "148",
                 "destinationNaptanId": "",
                 "destinationName": "Dulwich Library",
                 "timestamp": "2017-07-19T16:19:23Z",
                 "timeToStation": 1256,
                 "currentLocation": "",
                 "towards": "Parliament Square",
                 "expectedArrival": "2017-07-19T16:40:19Z",
                 "timeToLive": "2017-07-19T16:40:49Z",
                 "modeName": "bus",
                 "timing": {
                     "$type": "Tfl.Api.Presentation.Entities.PredictionTiming, Tfl.Api.Presentation.Entities",
                     "countdownServerAdjustment": "00:00:01.3886011",
                     "source": "2017-07-17T12:57:07.619Z",
                     "insert": "2017-07-19T16:19:04.749Z",
                     "read": "2017-07-19T16:19:04.749Z",
                     "sent": "2017-07-19T16:19:23Z",
                     "received": "0001-01-01T00:00:00Z"
                 }
             }]
             """.data(using: .utf8)
            nearbyBusStopsData = """
                {
                    "$type": "Tfl.Api.Presentation.Entities.StopPointsResponse, Tfl.Api.Presentation.Entities",
                    "centrePoint": [51.509, -0.133],
                    "stopPoints": [{
                        "$type": "Tfl.Api.Presentation.Entities.StopPoint, Tfl.Api.Presentation.Entities",
                        "naptanId": "490007960P",
                        "indicator": "Stop P",
                        "stopLetter": "P",
                        "modes": ["bus"],
                        "icsCode": "1007960",
                        "stopType": "NaptanPublicBusCoachTram",
                        "stationNaptan": "490G00007960",
                        "lines": [{
                            "$type": "Tfl.Api.Presentation.Entities.Identifier, Tfl.Api.Presentation.Entities",
                            "id": "12",
                            "name": "12",
                            "uri": "/Line/12",
                            "type": "Line",
                            "crowding": {
                                "$type": "Tfl.Api.Presentation.Entities.Crowding, Tfl.Api.Presentation.Entities"
                            }
                        }, {
                            "$type": "Tfl.Api.Presentation.Entities.Identifier, Tfl.Api.Presentation.Entities",
                            "id": "159",
                            "name": "159",
                            "uri": "/Line/159",
                            "type": "Line",
                            "crowding": {
                                "$type": "Tfl.Api.Presentation.Entities.Crowding, Tfl.Api.Presentation.Entities"
                            }
                        }],
                        "lineGroup": [{
                            "$type": "Tfl.Api.Presentation.Entities.LineGroup, Tfl.Api.Presentation.Entities",
                            "naptanIdReference": "490007960P",
                            "stationAtcoCode": "490G00007960",
                            "lineIdentifier": ["12", "159", "453", "88", "n109", "n136", "n18", "n3", "n97"]
                        }],
                        "lineModeGroups": [{
                            "$type": "Tfl.Api.Presentation.Entities.LineModeGroup, Tfl.Api.Presentation.Entities",
                            "modeName": "bus",
                            "lineIdentifier": ["12", "159", "453", "88", "n109", "n136", "n18", "n3", "n97"]
                        }],
                        "status": true,
                        "id": "490007960P",
                        "commonName": "Haymarket / Charles II Street",
                        "distance": 62.518072030038645,
                        "placeType": "StopPoint",
                        "additionalProperties": [],
                        "children": [],
                        "lat": 51.50898,
                        "lon": -0.132098
                    }, {
                        "$type": "Tfl.Api.Presentation.Entities.StopPoint, Tfl.Api.Presentation.Entities",
                        "naptanId": "490007960L",
                        "indicator": "Stop L",
                        "stopLetter": "L",
                        "modes": ["bus"],
                        "stopType": "NaptanPublicBusCoachTram",
                        "lines": [],
                        "lineGroup": [],
                        "lineModeGroups": [],
                        "id": "490007960L",
                        "commonName": "Piccadilly Circus  Haymarket",
                        "distance": 73.497394236195831,
                        "placeType": "StopPoint",
                        "additionalProperties": [],
                        "children": [],
                        "lat": 51.509637,
                        "lon": -0.13272
                    }, {
                        "$type": "Tfl.Api.Presentation.Entities.StopPoint, Tfl.Api.Presentation.Entities",
                        "naptanId": "490007960R",
                        "indicator": "Stop R",
                        "stopLetter": "R",
                        "modes": ["bus"],
                        "icsCode": "1020307",
                        "stopType": "NaptanPublicBusCoachTram",
                        "stationNaptan": "490G00020307",
                        "lines": [{
                            "$type": "Tfl.Api.Presentation.Entities.Identifier, Tfl.Api.Presentation.Entities",
                            "id": "139",
                            "name": "139",
                            "uri": "/Line/139",
                            "type": "Line",
                            "crowding": {
                                "$type": "Tfl.Api.Presentation.Entities.Crowding, Tfl.Api.Presentation.Entities"
                            }
                        }],
                        "lineGroup": [{
                            "$type": "Tfl.Api.Presentation.Entities.LineGroup, Tfl.Api.Presentation.Entities",
                            "naptanIdReference": "490007960R",
                            "stationAtcoCode": "490G00020307",
                            "lineIdentifier": ["139", "23", "6", "n113"]
                        }],
                        "lineModeGroups": [{
                            "$type": "Tfl.Api.Presentation.Entities.LineModeGroup, Tfl.Api.Presentation.Entities",
                            "modeName": "bus",
                            "lineIdentifier": ["139", "23", "6", "n113"]
                        }],
                        "status": true,
                        "id": "490007960R",
                        "commonName": "Haymarket / Jermyn Street",
                        "distance": 78.24560162994193,
                        "placeType": "StopPoint",
                        "additionalProperties": [],
                        "children": [],
                        "lat": 51.509683,
                        "lon": -0.132732
                    }],
                    "pageSize": 0,
                    "total": 0,
                    "page": 0
                }
                """.data(using: .utf8)
        }
        
        context("when calling arrivalsForStopPoint") {
            it("should issue request with the right URL") {
                var getDataCompletionBlockCalled = false
                testRequestManager.getDataCompletionBlock = { path in
                    expect(path).to(beginWith("/StopPoint/String/Arrivals"))
                    getDataCompletionBlockCalled = true
                    return (nil,nil)
                }
                client.arrivalsForStopPoint(with : "String") { _,_ in
                    
                }
                expect(getDataCompletionBlockCalled) == true
                                        
                    
            }
            
            pending("should call back on given queue on success") {
            }

            it("should call back on provided operation queue on failure") {
                var completionBlockCalled = false
                let queue = OperationQueue()
                client.arrivalsForStopPoint(with:"String",
                                            with: queue) { _,_ in
                     expect(queue.operationCount) == 1
                    completionBlockCalled = true
                }
                expect(completionBlockCalled).toEventually(beTrue())
                
            }
            it("should call back on mainqueue if no operation queue provided on failure") {
                var completionBlockCalled = false
                client.arrivalsForStopPoint(with:"String") { _,_ in
                                                expect(Thread.isMainThread) == true
                                                completionBlockCalled = true
                }
                expect(completionBlockCalled).toEventually(beTrue(),timeout:5)
            }

            it("should call back on mainqueue if no operation queue provided on success") {
                var completionBlockCalled = false
                testRequestManager.getDataCompletionBlock = { path in
                    return (arrivalsTestData,nil)
                }
                client.arrivalsForStopPoint(with:"String") { _,_ in
                    expect(Thread.isMainThread) == true
                    completionBlockCalled = true
                }
                expect(completionBlockCalled).toEventually(beTrue(),timeout:5)
            }
            it("should parse model successfully") {
                var completionBlockCalled = false
                testRequestManager.getDataCompletionBlock = { path in
                    expect(path).to(beginWith("/StopPoint/String/Arrivals"))
                    return (arrivalsTestData,nil)
                }
                client.arrivalsForStopPoint(with : "String") { models,_ in
                    completionBlockCalled = true
                    expect(models!.count) == 2
                }
                expect(completionBlockCalled).toEventually(beTrue())
            }
            
            it("should handle invalid model gracefully") {
                var completionBlockCalled = false
                let invalidTestData = """
                {"Hello" : "World"}
                """.data(using: .utf8)
                testRequestManager.getDataCompletionBlock = { path in
                    expect(path).to(beginWith("/StopPoint/String/Arrivals"))
                    return (invalidTestData,nil)
                }
                client.arrivalsForStopPoint(with : "String") { models,error in
                    completionBlockCalled = true
                    expect(models).to(beNil())
                }
                expect(completionBlockCalled).toEventually(beTrue(),timeout:5)
            }
        }
        
        context("When calling nearbyBusStops") {
            it("should issue request with the right URL") {
                var nearbyBusStopsBlockCalled = false
                testRequestManager.getDataCompletionBlock = { path in
                    expect(path).to(beginWith("/StopPoint"))
                    nearbyBusStopsBlockCalled = true
                    return (nil,nil)
                }
                client.nearbyBusStops(with :kCLLocationCoordinate2DInvalid) { _,_ in
                }
                expect(nearbyBusStopsBlockCalled) == true
            }
            
            pending("should call back on given queue on success") {
            }

            
            it("should call back on provided operation queue on failure") {
                var completionBlockCalled = false
                let queue = OperationQueue()
                client.nearbyBusStops(with :kCLLocationCoordinate2DInvalid,
                                            with: queue) { _,_ in
                                                expect(queue.operationCount) == 1
                                                completionBlockCalled = true
                }
                expect(completionBlockCalled).toEventually(beTrue(),timeout:5)
            }

            pending("should call back on mainqueue if no operation queue provided on success") {
                
            }

            pending("should call back on mainqueue if no operation queue provided on failure") {
                
            }

            it("should parse model successfully") {
                var completionBlockCalled = false
                testRequestManager.getDataCompletionBlock = { path in
                    return (nearbyBusStopsData,nil)
                }
                client.nearbyBusStops(with :kCLLocationCoordinate2DInvalid) { models,_ in
                    completionBlockCalled = true
                    expect(models!.count) == 3
                }
                expect(completionBlockCalled).toEventually(beTrue(),timeout:5)
            }
            
            it("should handle invalid model gracefully") {
                var completionBlockCalled = false
                testRequestManager.getDataCompletionBlock = { path in
                    let invalidTestData =  """
                        "{"Hello" : "World"}
                        """.data(using: .utf8)
                    return (invalidTestData,nil)
                }
                client.nearbyBusStops(with :kCLLocationCoordinate2DInvalid) { models,_ in
                    completionBlockCalled = true
                    expect(models).to(beNil())
                }
                expect(completionBlockCalled).toEventually(beTrue(),timeout:5)
            }

        }
       
        
        context("When calling busStops") {
            it("should issue request with the right URL") {
                var busStopsBlockCalled = false
                testRequestManager.getDataCompletionBlock = { path in
                    expect(path).to(beginWith("/StopPoint"))
                    busStopsBlockCalled = true
                    return (nil,nil)
                }
                client.busStops(with: 1) { _,_ in
                }
                expect(busStopsBlockCalled) == true
            }
            pending("should call back on given queue if no operation queue provided on failure") {
            }
            
            pending("should call back on given queue if no operation queue provided on success") {
            }

            it("should call back on mainQueue if no operation queue provided on failure") {
                var completionBlockCalled = false
                let queue = OperationQueue()
                client.busStops(with :1,
                                      with: queue) { _,_ in
                                        expect(Thread.isMainThread) == true
                                        completionBlockCalled = true
                }
                expect(completionBlockCalled).toEventually(beTrue(),timeout:5)
            }

            it("should call back on mainqueue if no operation queue provided on success") {
                var completionBlockCalled = false
                testRequestManager.getDataCompletionBlock = { path in
                    return (nearbyBusStopsData,nil)
                }
                client.busStops(with :1) { _,_ in
                    completionBlockCalled = true
                    expect(Thread.isMainThread) == true
                }
                expect(completionBlockCalled).toEventually(beTrue(),timeout:5)
            }
            
            it("should parse model successfully") {
                var completionBlockCalled = false
                testRequestManager.getDataCompletionBlock = { path in
                    return (nearbyBusStopsData,nil)
                }
                client.busStops(with :1) { models,_ in
                    completionBlockCalled = true
                    expect(models!.count) == 3
                }
                expect(completionBlockCalled).toEventually(beTrue(),timeout:5)
            }
            
            it("should handle invalid model gracefully") {
                var completionBlockCalled = false
                testRequestManager.getDataCompletionBlock = { path in
                    let invalidTestData =  """
                        "{"Hello" : "World"}
                        """.data(using: .utf8)
                    return (invalidTestData,nil)
                }
                client.busStops(with :1) { models,_ in
                    completionBlockCalled = true
                    expect(models).to(beNil())
                }
                expect(completionBlockCalled).toEventually(beTrue(),timeout:5)
            }

        }

     
    }
}
