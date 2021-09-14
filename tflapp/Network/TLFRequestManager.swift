import Foundation
import UIKit
import os.signpost
import CommonCrypto

enum TFLRequestManagerErrorType : Error {
    case InvalidURL(urlString : String)
}

protocol TFLRequestManagerDelegate : AnyObject {
    func didStartURLTask(with requestManager: TFLRequestManager,session : URLSession)
    func didFinishURLTask(with requestManager: TFLRequestManager,session : URLSession)
}

class TFLRequestManager : NSObject {
    let tfl_pupkeySet = Set(["bHDn2jpPdHC91AutvRw+ntQNGpN29nXp2Xk+l2MjMZU=","PKMxN8xff+xbsEgj97N+EY/F7zSEPX9ChA38bEojFbc="])
    weak var delegate : TFLRequestManagerDelegate?
    fileprivate let TFLRequestManagerBaseURL = "https://api.tfl.gov.uk"

    fileprivate static let loggingHandle  = OSLog(subsystem: TFLLogger.subsystem, category: TFLLogger.category.network.rawValue)

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
        let session = URLSession(configuration:  configuration,delegate:self,delegateQueue:nil)
        return session
        
    }()


    public func getDataWithRelativePath(relativePath: String ,and query: String? = nil) async throws -> Data {
        guard let url =  self.baseURL(withPath: relativePath,and: query) else {
            throw TFLRequestManagerErrorType.InvalidURL(urlString: relativePath)
        }
        return try await getDataWithURL(URL: url)
    }

   
    fileprivate func getDataWithURL(URL: URL) async throws -> Data {
        defer {
            self.delegate?.didFinishURLTask(with: self, session: self.session)
            TFLLogger.shared.signPostEnd(osLog: TFLRequestManager.loggingHandle, name: "getDataWithURL")
        }
        let urlRequest = URLRequest(url: URL)
        TFLLogger.shared.signPostStart(osLog: TFLRequestManager.loggingHandle, name: "getDataWithURL")
        self.delegate?.didStartURLTask(with: self, session: session)
        let (data,_) = try await session.data(for:urlRequest)

        return data
    }
}


extension TFLRequestManager : URLSessionDelegate {
    #if DEBUG
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
            let serverTrust = challenge.protectionSpace.serverTrust,
            let baseURL = NSURLComponents(string: TFLRequestManagerBaseURL),
            challenge.protectionSpace.host == baseURL.host else {
                return (.cancelAuthenticationChallenge, nil)
        }
        
        let isServerTrusted  = SecTrustEvaluateWithError(serverTrust,nil)

        guard isServerTrusted,let certificate = SecTrustGetCertificateAtIndex(serverTrust,0),
            let serverPublicKey = SecCertificateCopyKey(certificate),
            let serverPublicKeyData:NSData = SecKeyCopyExternalRepresentation(serverPublicKey, nil) else {
                 return(.cancelAuthenticationChallenge, nil)
        }
        let hash = (serverPublicKeyData as Data).sha256()
        guard let hashValue = hash,tfl_pupkeySet.contains(hashValue) else {
            return(.cancelAuthenticationChallenge, nil)
        }
        return(.useCredential, URLCredential(trust:serverTrust))
        
    }
   
    #endif
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
