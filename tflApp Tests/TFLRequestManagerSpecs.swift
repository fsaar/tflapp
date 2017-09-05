    
import Quick
import Nimble
import UIKit

@testable import London_Bus


typealias TestSessionTaskHandlerBlock = ((_ url : URL) -> (URLSessionDataTask))

    
fileprivate class TestDataTask : URLSessionDataTask {
    var resumeBlock : (()->())?
    
    override func resume() {
        resumeBlock?()
    }
}
    
fileprivate class TestSession : URLSession {
    var taskHandler : TestSessionTaskHandlerBlock
    var completionHandler : ((Data?, URLResponse?, Error?) -> Swift.Void)?
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Swift.Void) -> URLSessionDataTask {
        let dataTask = taskHandler(url)
        self.completionHandler = completionHandler
        return dataTask
    }
    
    init(using sessionTaskHandler : @escaping TestSessionTaskHandlerBlock) {
        self.taskHandler = sessionTaskHandler
    }
}

fileprivate class TestDataSource :  TFLRequestManagerDataSource {
    let session : URLSession
    func urlSession(for requestManager : TFLRequestManager) -> URLSession {
        return session
    }
    init(urlSession : URLSession) {
        self.session = urlSession
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
            manager = TFLRequestManager()
        }
        it("should issue request with the correct URL") {
            let arivalsPath = "/StopPoint/1234/Arrivals"
            let task = TestDataTask()
            let session = TestSession() { url in
                expect(url.absoluteString.hasPrefix("https://api.tfl.gov.uk/StopPoint/1234/Arrivals")) == true
                return task
            }
            let testDataSource = TestDataSource(urlSession : session)
            manager.dataSource = testDataSource
            manager.getDataWithRelativePath(relativePath: arivalsPath) { _, _ in
            }
        }
        
        context("in regards to delegate methods") {
            it("should inform datatask about started session") {
                let arivalsPath = "/StopPoint/1234/Arrivals"
                let task = TestDataTask()
                let session = TestSession() { url in
                    return task
                }
                let testDataSource = TestDataSource(urlSession : session)
                let testDelegate = TestDelegate()
                manager.dataSource = testDataSource
                manager.delegate = testDelegate
                manager.getDataWithRelativePath(relativePath: arivalsPath) { _, _ in
                }
                expect(testDelegate.didStartURLTask) == true
            }
            
            it("should inform datatask about stopped session") {
                let arivalsPath = "/StopPoint/1234/Arrivals"
                let task = TestDataTask()
                let session = TestSession() { url in
                    return task
                }
                let testDataSource = TestDataSource(urlSession : session)
                let testDelegate = TestDelegate()
                manager.dataSource = testDataSource
                manager.delegate = testDelegate
                manager.getDataWithRelativePath(relativePath: arivalsPath) { _, _ in
                }
                session.completionHandler!(nil,nil,nil)
                expect(testDelegate.didFinishURLTask) == true
            }
        }

     
    }
}
