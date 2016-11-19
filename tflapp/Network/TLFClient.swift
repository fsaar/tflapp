import Foundation
import CoreLocation
import CoreData

enum TFLClientError : Error {
    case InvalidFormat(data : Data?)
}

public final class TFLClient {
    
    lazy var tflManager : TFLRequestManager = TFLRequestManager.sharedManager
    
    public func arrivalsForStopPoint(with identifier: String, completionBlock:@escaping (([TFLBusPrediction]?,_ error:Error?) -> ()))  {
        let arivalsPath = "/StopPoint/\(identifier)/Arrivals"
        tflManager.getDataWithRelativePath(relativePath: arivalsPath) { data, error in
            if let data = data,
                let jsonList = try? JSONSerialization.jsonObject(with: data as Data
                    , options: JSONSerialization.ReadingOptions(rawValue:0)) as! [[String : Any]] {
                        var predictions : [TFLBusPrediction] = []
                        jsonList.forEach { dict in
                            if let prediction = TFLBusPrediction(with: dict) {
                                predictions += [prediction]
                            }
                        }
                OperationQueue.main.addOperation {
                    completionBlock(predictions,nil)
                }
            }
            else {
                
                OperationQueue.main.addOperation {
                    completionBlock(nil,error)
                }
            }
        }
    }
    
    public func nearbyBusStops(with coordinate: CLLocationCoordinate2D,completionBlock: @escaping (([TFLCDBusStop]?,_ error:Error?) -> ()))  {
        let busStopPath = "/StopPoint"
        let query = "lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&stopTypes=NaptanPublicBusCoachTram&categories=Geo"
        let context = TFLBusStopStack.sharedDataStack.privateQueueManagedObjectContext
        requestBusStops(with: busStopPath, query: query,context:context) {stops,error in
            if context.hasChanges {
                context.perform {
                    _ = try? context.save()
                }
            }
            completionBlock(stops,error)
        }

    }

    public func busStops(with page: UInt,completionBlock: @escaping (([TFLCDBusStop]?,_ error:Error?) -> ()))  {
        let busStopPath = "/StopPoint/Mode/bus"
        let query = "page=\(page+1)"
        requestBusStops(with: busStopPath, query: query,context:TFLCoreDataStack.sharedDataStack.privateQueueManagedObjectContext, completionBlock: completionBlock)
    }
    
}

fileprivate extension TFLClient {
    fileprivate func requestBusStops(with relativePath: String,query: String,context: NSManagedObjectContext, completionBlock: @escaping (([TFLCDBusStop]?,_ error:Error?) -> ()))  {
        tflManager.getDataWithRelativePath(relativePath: relativePath,and: query) { data, error in
            if let data = data,
                let jsonDict = try? JSONSerialization.jsonObject(with: data as Data
                    , options: JSONSerialization.ReadingOptions(rawValue:0)) as? [String : Any] {
                if let jsonList = jsonDict?["stopPoints"] as? [[String: Any]] {
                    let stops = jsonList.flatMap { TFLCDBusStop.busStop(with: $0,and:context ) }
                    OperationQueue.main.addOperation { completionBlock(stops,nil) }
                }
                else {
                    OperationQueue.main.addOperation { completionBlock(nil,TFLClientError.InvalidFormat(data: data)) }
                }
                
            }
            else {
                
                OperationQueue.main.addOperation {
                    completionBlock(nil,error)
                }
            }
        }
    }
}

