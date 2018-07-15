    
import Quick
import Nimble
import CoreLocation
import UIKit

@testable import London_Bus

enum TestError : Error {
    case test
}
    
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
    
private class TestQueue : OperationQueue {
    var added = false
    override func addOperation(_ op: Operation) {
        op.start()
        added = true
    }
    
    override func addOperations(_ ops: [Operation], waitUntilFinished wait: Bool) {
        ops.forEach { $0.start() }
        added = true
    }
}
        
    
class TFLClientSpecs: QuickSpec {
    
    override func spec() {
        var client : TFLClient!
        var testRequestManager : TestRequestManager!
        var arrivalsTestData : Data!
        var nearbyBusStopsData : Data!
        beforeEach() {
            let dataWithJSONFile : (_ jsonFileName: String) -> Data = { jsonFileName in
                let url = Bundle(for: type(of:self)).url(forResource: jsonFileName, withExtension: "json")
                return try! Data(contentsOf: url!)
            }
            client = TFLClient()
            testRequestManager = TestRequestManager()
            client.tflManager = testRequestManager
            
            arrivalsTestData = dataWithJSONFile("Arrivals")
            nearbyBusStopsData = dataWithJSONFile("Busstops")
        }
        
        context("when calling arrivalsForStopPoint") {
            var queue : TestQueue!
            
            beforeEach() {
                queue = TestQueue()
            }

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
            
            it("should call back on given queue on success") {
                var completionBlockCalled = false
                testRequestManager.getDataCompletionBlock = { path in
                    return (arrivalsTestData,nil)
                }
                client.arrivalsForStopPoint(with:"String",
                                            with: queue) { _,error in
                                                completionBlockCalled = true
                                                expect(error).to(beNil())
                                                completionBlockCalled = true
                }
                expect(queue.added) == true
                expect(completionBlockCalled) == true
            }

            it("should call back on provided operation queue on failure") {
                var completionBlockCalled = false
                client.arrivalsForStopPoint(with:"String",
                                            with: queue) { _,error in
                                                expect(error).notTo(beNil())
                    completionBlockCalled = true
                }
                expect(queue.added) == true
                expect(completionBlockCalled) == true
                
            }
            it("should call back on mainqueue if no operation queue provided on failure") {
                var completionBlockCalled = false
                client.arrivalsForStopPoint(with:"String") { _,error in
                    expect(error).notTo(beNil())
                    expect(Thread.isMainThread) == true
                    completionBlockCalled = true
                }
                expect(completionBlockCalled).toEventually(beTrue(),timeout:99)
            }

            it("should call back on mainqueue if no operation queue provided on success") {
                var completionBlockCalled = false
                testRequestManager.getDataCompletionBlock = { path in
                    return (arrivalsTestData,nil)
                }
                client.arrivalsForStopPoint(with:"String") { _,error in
                    expect(error).to(beNil())
                    expect(Thread.isMainThread) == true
                    completionBlockCalled = true
                }
                expect(completionBlockCalled).toEventually(beTrue(),timeout:99)
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
                expect(completionBlockCalled).toEventually(beTrue(),timeout:99)
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
                expect(completionBlockCalled).toEventually(beTrue(),timeout:99)
            }
        }
        
        context("When calling nearbyBusStops") {
            var queue : TestQueue!
            
            beforeEach() {
                queue = TestQueue()
            }
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
            
            it("should call back on given queue on success") {
                var completionBlockCalled = false
                testRequestManager.getDataCompletionBlock = { path in
                    return (nearbyBusStopsData,nil)
                }
                client.nearbyBusStops(with :kCLLocationCoordinate2DInvalid,
                                      with: queue) { _,error in
                                        expect(error).to(beNil())
                                        completionBlockCalled = true
                }
                expect(queue.added).toEventually(beTrue(),timeout:99)
                expect(completionBlockCalled).toEventually(beTrue(),timeout:99)
            }

            
            it("should call back on provided operation queue on failure") {
                var completionBlockCalled = false
                client.nearbyBusStops(with :kCLLocationCoordinate2DInvalid,
                                            with: queue) { _,error in
                                                expect(error).notTo(beNil())
                                                completionBlockCalled = true
                }
                expect(queue.added).toEventually(beTrue(),timeout:99)
                expect(completionBlockCalled).toEventually(beTrue(),timeout:99)
            }

            it("should call back on mainqueue if no operation queue provided on success") {
                var completionBlockCalled = false
                testRequestManager.getDataCompletionBlock = { path in
                    return (nearbyBusStopsData,nil)
                }
                client.nearbyBusStops(with :kCLLocationCoordinate2DInvalid) { _,error in
                    expect(error).to(beNil())
                    completionBlockCalled = true
                    expect(Thread.isMainThread) == true
                }
                expect(completionBlockCalled).toEventually(beTrue(),timeout:99)
            }

            it("should call back on mainqueue if no operation queue provided on failure") {
                var completionBlockCalled = false
                testRequestManager.getDataCompletionBlock = { path in
                    return (nil,TestError.test)
                }
                client.nearbyBusStops(with :kCLLocationCoordinate2DInvalid) { _,error in
                    expect(error).notTo(beNil())
                    completionBlockCalled = true
                    expect(Thread.isMainThread) == true
                }
                expect(completionBlockCalled).toEventually(beTrue(),timeout:99)
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
                expect(completionBlockCalled).toEventually(beTrue(),timeout:99)
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
                expect(completionBlockCalled).toEventually(beTrue(),timeout:99)
            }

        }
       
        
        context("When calling busStops") {
            var queue : TestQueue!
            
            beforeEach() {
                queue = TestQueue()
            }
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
            it("should call back on given queue if operation queue provided on failure") {
                var completionBlockCalled = false
                testRequestManager.getDataCompletionBlock = { path in
                    return (nil,TestError.test)
                }
                client.busStops(with :1,
                                with: queue) { _,error in
                                    expect(error).notTo(beNil())
                                    completionBlockCalled = true
                }
                expect(queue.added).toEventually(beTrue(),timeout:99)
                expect(completionBlockCalled).toEventually(beTrue(),timeout:99)
            }
            
            it("should call back on given queue if operation queue provided on success") {
                var completionBlockCalled = false
                testRequestManager.getDataCompletionBlock = { path in
                    return (nearbyBusStopsData,nil)
                }
                client.busStops(with :1,
                                with: queue) { _,error in
                                    expect(error).to(beNil())
                                    completionBlockCalled = true
                }
                expect(queue.added).toEventually(beTrue(),timeout:99)
                expect(completionBlockCalled).toEventually(beTrue(),timeout:99)
            }

            it("should call back on mainQueue if no operation queue provided on failure") {
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
                testRequestManager.getDataCompletionBlock = { path in
                    return (nearbyBusStopsData,nil)
                }
                client.busStops(with :1) { _,error in
                    expect(error).to(beNil())
                    completionBlockCalled = true
                    expect(Thread.isMainThread) == true
                }
                expect(completionBlockCalled).toEventually(beTrue(),timeout:99)
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
                expect(completionBlockCalled).toEventually(beTrue(),timeout:99)
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
                expect(completionBlockCalled).toEventually(beTrue(),timeout:99)
            }

        }

     
    }
}
