    
import Quick
import Nimble
import CoreLocation
import UIKit

@testable import BusStops

    
private class TestQueue : OperationQueue {
    var added = false
    override func addOperation(_ op: Operation) {
        added = true
        op.start()
    }
    
    override func addOperations(_ ops: [Operation], waitUntilFinished wait: Bool) {
        added = true
        ops.forEach { $0.start() }
    }
}
        
    
class TFLClientSpecs: QuickSpec {

    override func spec() {
        var client : TFLClient!

        beforeEach() {
            client = TFLClient()
            URLProtocol.registerClass(TestUrlProtocol.self)
            let configuration = URLSessionConfiguration.default
            configuration.protocolClasses = [TestUrlProtocol.self]
            TFLRequestManager.shared.session = URLSession(configuration:configuration)
        }
        afterEach {
            TestUrlProtocol.dataProviders = []
        }
        
        context("when calling arrivalsForStopPoint") {
            var queue : TestQueue!
            
            beforeEach() {
                queue = TestQueue()
                TestUrlProtocol.addDataProvider { request in
                    guard request.url!.absoluteString.contains("/StopPoint/success/Arrivals") else {
                        return nil
                    }
                    return self.dataWithJSONFile("Arrivals")
                }
            }

            it("should issue request with the right URL") {
                 var completionBlockCalled = false
               
                client.arrivalsForStopPoint(with : "fail") { _,error in
                    expect(error).notTo(beNil())
                    completionBlockCalled = true
                }
                expect(completionBlockCalled).toEventually(beTrue(),timeout: 10)

            }
            
            it("should call back on given queue on success") {
                var completionBlockCalled = false
                
                client.arrivalsForStopPoint(with:"success",
                                            with: queue) { _,error in
                                                expect(queue.added) == true
                                                completionBlockCalled = true
                                                expect(error).to(beNil())
                }
                expect(completionBlockCalled).toEventually(beTrue(),timeout: 10)
            }

            it("should call back on provided operation queue on failure") {
                var completionBlockCalled = false
                client.arrivalsForStopPoint(with:"failure",
                                            with: queue) { _,error in
                                                expect(queue.added) == true
                                                expect(error).notTo(beNil())
                    completionBlockCalled = true
                }
                expect(completionBlockCalled).toEventually(beTrue(),timeout: 99)

            }
            it("should call back on mainqueue if no operation queue provided on failure") {
                var completionBlockCalled = false
                client.arrivalsForStopPoint(with:"failed") { _,error in
                    expect(error).notTo(beNil())
                    expect(Thread.isMainThread) == true
                    completionBlockCalled = true
                }
                expect(completionBlockCalled).toEventually(beTrue(),timeout: 99)
            }

            it("should call back on mainqueue if no operation queue provided on success") {
                var completionBlockCalled = false
                client.arrivalsForStopPoint(with:"success") { _,error in
                    expect(error).to(beNil())
                    expect(Thread.isMainThread) == true
                    completionBlockCalled = true
                }
                expect(completionBlockCalled).toEventually(beTrue(),timeout: 99)
            }
            it("should parse model successfully") {
                var completionBlockCalled = false
                client.arrivalsForStopPoint(with : "success") { models,_ in
                    completionBlockCalled = true
                    expect(models!.count) == 2
                }
                expect(completionBlockCalled).toEventually(beTrue(),timeout: 99)
            }

            it("should handle invalid model gracefully") {
                TestUrlProtocol.dataProviders = []
                TestUrlProtocol.addDataProvider { request in
                    guard request.url!.absoluteString.contains("/StopPoint/fail/Arrivals") else {
                        return nil
                    }
                    let invalidTestData = "['Hello' : 'World']".data(using: .utf8)
                    return invalidTestData
                }
                
                var completionBlockCalled = false
                
                client.arrivalsForStopPoint(with : "fail") { models,error in
                    completionBlockCalled = true
                    expect(models).to(beNil())
                }
                expect(completionBlockCalled).toEventually(beTrue(),timeout: 99)
            }
        }
        
        context("When calling nearbyBusStops") {
            var queue : TestQueue!

            beforeEach() {
                queue = TestQueue()
                TestUrlProtocol.addDataProvider { request in
                    guard request.url!.absoluteString.contains("/StopPoint") else {
                        return nil
                    }
                    let data = self.dataWithJSONFile("Busstops")
                    return data
                }

            }
            it("should issue request with the right URL") {
                var nearbyBusStopsBlockCalled = false
                client.nearbyBusStops(with :kCLLocationCoordinate2DInvalid) { models,_ in
                    expect(models).notTo(beNil())
                    nearbyBusStopsBlockCalled = true
                }
               expect(nearbyBusStopsBlockCalled).toEventually(beTrue(),timeout: 99)
            }

            it("should call back on given queue on success") {
                var completionBlockCalled = false
                client.nearbyBusStops(with :kCLLocationCoordinate2DInvalid,
                                      with: queue) { _,error in
                                        expect(error).to(beNil())
                                        expect(queue.added) == true
                                        completionBlockCalled = true
                }
                
                expect(completionBlockCalled).toEventually(beTrue(),timeout:99)
            }


            it("should call back on provided operation queue on failure") {
                TestUrlProtocol.dataProviders = []
                var completionBlockCalled = false
                client.nearbyBusStops(with :kCLLocationCoordinate2DInvalid,
                                            with: queue) { _,error in
                                                expect(error).notTo(beNil())
                                                expect(queue.added) == true
                                                completionBlockCalled = true
                }
              
                expect(completionBlockCalled).toEventually(beTrue(),timeout:99)
            }

            it("should call back on mainqueue if no operation queue provided on success") {
                var completionBlockCalled = false
                client.nearbyBusStops(with :kCLLocationCoordinate2DInvalid) { _,error in
                    expect(error).to(beNil())
                    completionBlockCalled = true
                    expect(Thread.isMainThread) == true
                }
                expect(completionBlockCalled).toEventually(beTrue(),timeout:99)
            }

            it("should call back on mainqueue if no operation queue provided on failure") {
                var completionBlockCalled = false
                TestUrlProtocol.dataProviders = []
                client.nearbyBusStops(with :kCLLocationCoordinate2DInvalid) { _,error in
                    expect(error).notTo(beNil())
                    completionBlockCalled = true
                    expect(Thread.isMainThread) == true
                }
                expect(completionBlockCalled).toEventually(beTrue(),timeout:99)
            }

            it("should parse model successfully") {
                var completionBlockCalled = false
                client.nearbyBusStops(with :kCLLocationCoordinate2DInvalid) { models,_ in
                    completionBlockCalled = true
                    expect(models!.count) == 3
                }
                expect(completionBlockCalled).toEventually(beTrue(),timeout:99)
            }

            it("should handle invalid model gracefully") {
                TestUrlProtocol.dataProviders = []
                TestUrlProtocol.addDataProvider { request in
                    let invalidTestData = "['Hello' : 'World']".data(using: .utf8)
                    return invalidTestData
                }
                var completionBlockCalled = false
                
                client.nearbyBusStops(with :kCLLocationCoordinate2DInvalid) { models,_ in
                    completionBlockCalled = true
                    expect(models).to(beNil())
                }
                expect(completionBlockCalled).toEventually(beTrue(),timeout:99)
            }

        }


        context("When calling busStops") {
            var queue : TestQueue!

            beforeEach() {
                queue = TestQueue()
                TestUrlProtocol.addDataProvider { request in
                    guard request.url!.absoluteString.contains("/StopPoint/Mode/bus") else {
                        return nil
                    }
                    let data = self.dataWithJSONFile("Busstops")
                    return data
                }
            }
            it("should issue request with the right URL") {
                var busStopsBlockCalled = false
     
                client.busStops(with: 1,with: .main) { models,_ in
                    busStopsBlockCalled = true
                    expect(models).notTo(beNil())
                }
                expect(busStopsBlockCalled).toEventually(beTrue(),timeout:99)
            }
            it("should call back on given queue if operation queue provided on failure") {
                TestUrlProtocol.dataProviders = []

                var completionBlockCalled = false
                client.busStops(with :1,
                                with: queue) { _,error in
                                    expect(error).notTo(beNil())
                                    expect(queue.added) == true
                                    completionBlockCalled = true
                }
                
                expect(completionBlockCalled).toEventually(beTrue(),timeout:99)
            }

            it("should call back on given queue if operation queue provided on success") {
                var completionBlockCalled = false
                client.busStops(with :1,
                                with: queue) { _,error in
                                    expect(error).to(beNil())
                                    expect(queue.added) == true
                                    completionBlockCalled = true
                }
                expect(completionBlockCalled).toEventually(beTrue(),timeout:99)
            }

            it("should call back on mainQueue if no operation queue provided on failure") {
                TestUrlProtocol.dataProviders = []
                var completionBlockCalled = false
                client.busStops(with :1) { _,error in
                    expect(error).notTo(beNil())
                    expect(Thread.isMainThread) == true
                    completionBlockCalled = true
                }
                expect(completionBlockCalled).toEventually(beTrue(),timeout:99)
            }

            it("should call back on mainqueue if no operation queue provided on success") {
                var completionBlockCalled = false
                client.busStops(with :1) { _,error in
                    expect(error).to(beNil())
                    completionBlockCalled = true
                    expect(Thread.isMainThread) == true
                }
                expect(completionBlockCalled).toEventually(beTrue(),timeout:99)
            }

            it("should parse model successfully") {
                var completionBlockCalled = false
                client.busStops(with :1) { models,_ in
                    completionBlockCalled = true
                    expect(models!.count) == 3
                }
                expect(completionBlockCalled).toEventually(beTrue(),timeout:99)
            }

            it("should handle invalid model gracefully") {
                TestUrlProtocol.dataProviders = []
                TestUrlProtocol.addDataProvider { request in
                    let invalidTestData = "['Hello' : 'World']".data(using: .utf8)
                    return invalidTestData
                }
                var completionBlockCalled = false
                client.busStops(with :1) { models,_ in
                    completionBlockCalled = true
                    expect(models).to(beNil())
                }
                expect(completionBlockCalled).toEventually(beTrue(),timeout:99)
            }

        }

     
    }
}
