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
    let tfl_pupkey = "uyOeNu35g/rCrOt2wlgXgISGx9Xw48B4Z8SiTrdEwhQ="
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


    public func getDataWithRelativePath(relativePath: String ,and query: String? = nil, completionBlock:@escaping ((_ data : Data?,_ error:Error?) -> Void)) {
        guard let url =  self.baseURL(withPath: relativePath,and: query) else {
            completionBlock(nil,TFLRequestManagerErrorType.InvalidURL(urlString: relativePath))
            return
        }
        getDataWithURL(URL: url,completionBlock: completionBlock)
    }

   
    fileprivate func getDataWithURL(URL: URL , completionBlock:@escaping ((_ data : Data?,_ error:Error?) -> Void)) {
        let task = session.dataTask(with: URL) { [weak self] data, _, error in
            TFLLogger.shared.signPostEnd(osLog: TFLRequestManager.loggingHandle, name: "getDataWithURL")

            if let self = self {
                self.delegate?.didFinishURLTask(with: self, session: self.session)

            }
            completionBlock(data,error)
        }
        task.resume()
        TFLLogger.shared.signPostStart(osLog: TFLRequestManager.loggingHandle, name: "getDataWithURL")

        self.delegate?.didStartURLTask(with: self, session: session)
    }
}


extension TFLRequestManager : URLSessionDelegate {
    #if !DEBUG
    func urlSession(_ session: URLSession,
                    didReceive challenge: URLAuthenticationChallenge,
                    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
            let serverTrust = challenge.protectionSpace.serverTrust,
            let baseURL = NSURLComponents(string: TFLRequestManagerBaseURL),
            challenge.protectionSpace.host == baseURL.host else {
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
        }
        
        let isServerTrusted  = SecTrustEvaluateWithError(serverTrust,nil)
        
        guard isServerTrusted,let certificate = SecTrustGetCertificateAtIndex(serverTrust, 0),
            let serverPublicKey = SecCertificateCopyKey(certificate),
            let serverPublicKeyData:NSData = SecKeyCopyExternalRepresentation(serverPublicKey, nil ),
            (serverPublicKeyData as Data).sha256() == tfl_pupkey else {
                completionHandler(.cancelAuthenticationChallenge, nil)
                return
                
        }
        completionHandler(.useCredential, URLCredential(trust:serverTrust))
        
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
