import Foundation
import UIKit
import OSLog
import CommonCrypto

enum TFLRequestManagerErrorType : Error {
    case InvalidURL(urlString : String)
}

protocol TFLRequestManagerDelegate : AnyObject {
    func didStartURLTask(with requestManager: TFLRequestManager,session : URLSession)
    func didFinishURLTask(with requestManager: TFLRequestManager,session : URLSession)
}

class TFLRequestManager : NSObject {
    weak var delegate : TFLRequestManagerDelegate?
    fileprivate let TFLRequestManagerBaseURL = "https://api.tfl.gov.uk"

    fileprivate let logger  = Logger(subsystem: TFLLogger.subsystem, category: TFLLogger.category.network.rawValue)

    fileprivate let TFLApplicationID = "PASTE_YOUR_APPLICATION_ID_HERE"
    fileprivate let TFLApplicationKey = "PASTE_YOUR_APPLICATION_KEY_HERE"
    public static let shared =  TFLRequestManager()

    var protocolClasses : [AnyClass] = [] {
        didSet {
            let configuration = URLSessionConfiguration.default
            configuration.protocolClasses = self.protocolClasses
            self.session = URLSession(configuration:configuration)
        }
    }
    
    lazy var session : URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForResource = 120
        configuration.timeoutIntervalForRequest = 60
        let session = URLSession(configuration:  configuration,delegate:nil,delegateQueue:nil)
        return session
        
    }()


    public func getDataWithRelativePath(relativePath: String ,and query: String? = nil) async throws -> Data {
        guard let url =  self.baseURL(withPath: relativePath,and: query) else {
            throw TFLRequestManagerErrorType.InvalidURL(urlString: relativePath)
        }
        let data = try await getDataWithURL(URL: url)
        return data
    }

    
    fileprivate func getDataWithURL(URL: URL) async throws -> Data {
        logger.log("Start network request: \(URL)")
        self.delegate?.didStartURLTask(with: self, session: session)
        let (data,_) =  try await session.data(from: URL)
        logger.log("Stop network request: \(URL)")
        self.delegate?.didFinishURLTask(with: self, session: self.session)
        return data
    }
    
}


// MARK: Private

fileprivate extension TFLRequestManager {
     func baseURL(withPath path: String,and query: String? = nil) -> URL? {
        guard let baseURL = NSURLComponents(string: TFLRequestManagerBaseURL) else {
            return nil
        }
        baseURL.path = path
        let auth = "app_id=\(TFLApplicationID)&app_key=\(TFLApplicationKey)"
        if let query = query {
            baseURL.query = query+"&"+auth
        }
        else
        {
            baseURL.query = auth
        }
        return baseURL.url
    }
}
