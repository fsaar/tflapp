    
import Quick
import Nimble
import UIKit

@testable import BusStops


typealias TestSessionTaskHandlerBlock = ((_ url : URL) -> (URLSessionDataTask))

    
fileprivate class TestDataTask : URLSessionDataTask {
    var resumeBlock : (()->())?
    
    override func resume() {
        resumeBlock?()
    }
}
 

fileprivate class TestDelegate :  TFLRequestManagerDelegate {
    var didStartURLTask : Bool = false
    var didFinishURLTask : Bool = false
    func didStartURLTask(with requestManager: TFLRequestManager,session : URLSession) {
        didStartURLTask = true
    }
    func didFinishURLTask(with requestManager: TFLRequestManager,session : URLSession) {
        didFinishURLTask = true
    }
}
    
class TFLRequestManagerSpecs: QuickSpec {
    override func spec() {
        var manager : TFLRequestManager!
        beforeEach() {
            manager = TFLRequestManager.shared
            URLProtocol.registerClass(TestUrlProtocol.self)
            let configuration = URLSessionConfiguration.default
            configuration.protocolClasses = [TestUrlProtocol.self]
            TFLRequestManager.shared.session = URLSession(configuration:configuration)

        }
        afterEach {
            TestUrlProtocol.dataProviders = []
        }

        
        it("should issue request with the correct URL") {
            let arivalsPath = "/StopPoint/1234/Arrivals"
            var didIssueCall = false
            TestUrlProtocol.addDataProvider { request in
                guard request.url!.absoluteString.contains(arivalsPath) else {
                    return nil
                }
                didIssueCall = true
                return self.dataWithJSONFile("Arrivals")
            }
            manager.getDataWithRelativePath(relativePath: arivalsPath) { _, _ in
            }
            expect(didIssueCall).toEventually(beTrue(),timeout:99)
        }
        
        context("in regards to delegate methods") {
            it("should inform datatask about started session") {
                let arivalsPath = "/StopPoint/1234/Arrivals"
                TestUrlProtocol.addDataProvider { _ in
                    return nil
                }
                let testDelegate = TestDelegate()
                manager.delegate = testDelegate
                manager.getDataWithRelativePath(relativePath: arivalsPath) { _, _ in
                }
                expect(testDelegate.didStartURLTask) == true
            }

            it("should inform datatask about stopped session") {
                let arivalsPath = "/StopPoint/1234/Arrivals"
                TestUrlProtocol.addDataProvider { _ in
                    return nil
                }
                let testDelegate = TestDelegate()
                manager.delegate = testDelegate
                manager.getDataWithRelativePath(relativePath: arivalsPath) { _, _ in
                }
                expect(testDelegate.didFinishURLTask).toEventually(beTrue(),timeout:99)
            }
        }
    }
}
