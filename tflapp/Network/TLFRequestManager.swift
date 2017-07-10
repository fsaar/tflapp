import Foundation
import UIKit

enum TFLRequestManagerErrorType : Error {
    case InvalidURL(urlString : String)
}

protocol TFLRequestManagerDelegate : class {
    func didStartURLTask(with requestManager: TFLRequestManager,session : URLSession)
    func didFinishURLTask(with requestManager: TFLRequestManager,session : URLSession)
}

public final class TFLRequestManager : NSObject {
    weak var delegate : TFLRequestManagerDelegate?
    fileprivate let TFLRequestManagerBaseURL = "https://api.tfl.gov.uk"
    static let sessionID =  "group.tflwidgetSharingData.sessionconfiguration"

    fileprivate var backgroundCompletionHandler : (session:(()->())?,caller:(()->())?)?
    fileprivate let TFLApplicationID = "528a18f1"
    fileprivate let TFLApplicationKey = "86f44a61de39e94b3738d9fe6cfcdf35"
    public static let sharedManager =  TFLRequestManager()
    
    fileprivate let session = URLSession(configuration: URLSessionConfiguration.default)

    
    public func getDataWithRelativePath(relativePath: String ,and query: String? = nil, completionBlock:@escaping ((_ data : Data?,_ error:Error?) -> Void)) {
        guard let url =  self.baseURL(withPath: relativePath,and: query) else {
            completionBlock(nil,TFLRequestManagerErrorType.InvalidURL(urlString: relativePath))
            return
        }
        getDataWithURL(URL: url,completionBlock: completionBlock)
    }
    
    func handleEventsForBackgroundURLSession(with identifier: String, completionHandler: @escaping () -> Void) {
        guard identifier == TFLRequestManager.sessionID,case .none = backgroundCompletionHandler else {
            return
        }
        self.backgroundCompletionHandler?.session = completionHandler
    }
    


    fileprivate func getDataWithURL(URL: URL , completionBlock:@escaping ((_ data : Data?,_ error:Error?) -> Void)) {
        let task = session.dataTask(with: URL, completionHandler: { [weak self] (data, _, error) -> (Void) in
            
            if let strongSelf = self {
                strongSelf.delegate?.didFinishURLTask(with: strongSelf, session: strongSelf.session)
                
            }
            completionBlock(data,error)
        })
        task.resume()
        self.delegate?.didStartURLTask(with: self, session: session)
    }
    
    
}


// MARK : Private

extension TFLRequestManager {
    fileprivate func baseURL(withPath path: String,and query: String? = nil) -> URL? {
        let baseURL = NSURLComponents(string: TFLRequestManagerBaseURL)
        if let baseURL = baseURL {
            let auth = "app_id=\(TFLApplicationID)&app_key=\(TFLApplicationKey)"
            baseURL.path = path
            if let query = query {
                baseURL.query = query+"&"+auth
            }
            else
            {
                baseURL.query = auth
            }
            return baseURL.url
        }
        return nil
    }
    
}
