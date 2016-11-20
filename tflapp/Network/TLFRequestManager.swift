import Foundation
import UIKit

enum TFLRequestManagerErrorType : Error {
    case InvalidURL(urlString : String)
}

public final class TFLRequestManager {
    fileprivate let TFLRequestManagerBaseURL = "https://api.tfl.gov.uk"
    
    fileprivate let TFLApplicationID = "PASTE_YOUR_APPLICATION_ID_HERE"
    fileprivate let TFLApplicationKey = "PASTE_YOUR_APPLICATION_KEY_HERE"
    public static let sharedManager =  TFLRequestManager()
    
    private let session = URLSession(configuration: URLSessionConfiguration.default)

    public func getDataWithRelativePath(relativePath: String ,and query: String? = nil, completionBlock:@escaping ((_ data : Data?,_ error:Error?) -> Void)) {
        guard let url =  self.baseURL(withPath: relativePath,and: query) else {
            completionBlock(nil,TFLRequestManagerErrorType.InvalidURL(urlString: relativePath))
            return
        }
        getDataWithURL(URL: url,completionBlock: completionBlock)
    }

    fileprivate func getDataWithURL(URL: URL , completionBlock:@escaping ((_ data : Data?,_ error:Error?) -> Void)) {
        let task = session.dataTask(with: URL, completionHandler: { [weak self] (data, _, error) -> (Void) in
            self?.session.getAllTasks { tasks in
                UIApplication.shared.isNetworkActivityIndicatorVisible = !tasks.isEmpty
            }
            
            completionBlock(data,error)
        })
        task.resume()
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
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
