import Foundation

typealias TestUrlProtocolDataProvider = (_ request : URLRequest)-> Data?


class TestUrlProtocol: URLProtocol {
    enum TestUrlProtocolError : Error {
        case noData
    }

    static var dataProviders : [TestUrlProtocolDataProvider] = []
    static func addDataProvider(_ provider : @escaping TestUrlProtocolDataProvider) {
        dataProviders += [provider]
    }
    
    open override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    open override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        
        let data = TestUrlProtocol.dataProviders.lazy.compactMap { dataProvider in
            return dataProvider(self.request)
        }.first
        if let data = data {
            self.client!.urlProtocol(self, didLoad: data)
        }
        else {
            self.client!.urlProtocol(self, didFailWithError: TestUrlProtocolError.noData)
        }
        self.client!.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {
    }
    
    
}
