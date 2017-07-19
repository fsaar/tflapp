    
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
        beforeEach() {
            client = TFLClient()
            testRequestManager = TestRequestManager()
            client.tflManager = testRequestManager
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

            pending("should call back on mainqueue if no operation queue provided on success") {
                
            }
            pending("should parse model successfully") {
                
            }
            
            pending("should handle invalid model gracefully") {
                
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
            
            it("should call back on provided operation queue on failure") {
                var completionBlockCalled = false
                let queue = OperationQueue()
                client.nearbyBusStops(with :kCLLocationCoordinate2DInvalid,
                                            with: queue) { _,_ in
                                                expect(queue.operationCount) == 1
                                                completionBlockCalled = true
                }
                expect(completionBlockCalled).toEventually(beTrue())
            }

            pending("should call back on mainqueue if no operation queue provided") {
                
            }
            
            pending("should parse model successfully") {
                
            }
            
            pending("should handle invalid model gracefully") {
                
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
            
            it("should call back on mainqueue if no operation queue provided on failure") {
                var completionBlockCalled = false
                let queue = OperationQueue()
                client.busStops(with :1,
                                      with: queue) { _,_ in
                                        expect(queue.operationCount) == 1
                                        completionBlockCalled = true
                }
                expect(completionBlockCalled).toEventually(beTrue())
            }

            pending("should call back on mainqueue if no operation queue provided on success") {
                
            }
            
            pending("should parse model successfully") {
                
            }
            
            pending("should handle invalid model gracefully") {
                
            }

        }

     
    }
}
