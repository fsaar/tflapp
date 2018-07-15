import Foundation

class TestUrlProtocol: URLProtocol {
    
    var data : Data?
    
    open override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    open override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        if let data = data {
            self.client!.urlProtocol(self, didLoad: data)
        }
        self.client!.urlProtocolDidFinishLoading(self)
    }
    
    
}
