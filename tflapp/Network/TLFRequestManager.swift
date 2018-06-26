import Foundation
import UIKit

enum TFLRequestManagerErrorType : Error {
    case InvalidURL(urlString : String)
}


protocol TFLRequestManagerDelegate : class {
    func didStartURLTask(with requestManager: TFLRequestManager,session : URLSession)
    func didFinishURLTask(with requestManager: TFLRequestManager,session : URLSession)
}

protocol TFLRequestManagerDataSource : class {
    func urlSession(for requestManager : TFLRequestManager) -> URLSession
}

public class TFLRequestManager : NSObject {
    weak var delegate : TFLRequestManagerDelegate?
    weak var dataSource : TFLRequestManagerDataSource?
    fileprivate let TFLRequestManagerBaseURL = "https://api.tfl.gov.uk"
    static let sessionID =  "group.tflwidgetSharingData.sessionconfiguration"

    fileprivate var backgroundCompletionHandler : (session:(()->())?,caller:(()->())?)?
    fileprivate let TFLApplicationID = "PASTE_YOUR_APPLICATION_ID_HERE"
    fileprivate let TFLApplicationKey = "PASTE_YOUR_APPLICATION_KEY_HERE"
    public static let shared =  TFLRequestManager()

    fileprivate lazy var session = { () -> URLSession in
        if let session = self.dataSource?.urlSession(for: self)  {
            return session
        }
        return URLSession(configuration: URLSessionConfiguration.default)
    }()


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
