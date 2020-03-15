
import Foundation
import CoreLocation
import CoreData
import os.signpost

enum TFLClientError : Error {
    case InvalidFormat(data : Data?)
    case InvalidLine
}

public final class TFLClient {
    static let jsonDecoder = { ()-> JSONDecoder in
        let decoder = JSONDecoder()
        return decoder
    }()
    lazy var tflManager  = TFLRequestManager.shared
    fileprivate static let loggingHandle : OSLog =  {
        let handle = OSLog(subsystem: TFLLogger.subsystem, category: TFLLogger.category.api.rawValue)
        return handle
    }()
    let backgroundQueue : OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .userInitiated
        return queue
    }()
    
    public func vehicleArrivalsInfo(with vehicleId: String,
                                     with operationQueue : OperationQueue = OperationQueue.main,
                                     using completionBlock:@escaping (([TFLVehicleArrivalInfo]?,_ error:Error?) -> ()))  {
        
        let vehicleArrivalsInfoPath = "/Vehicle/\(vehicleId)/Arrivals"
        TFLLogger.shared.signPostStart(osLog: TFLClient.loggingHandle, name: "vehicleInfo",identifier: vehicleId)
        tflManager.getDataWithRelativePath(relativePath: vehicleArrivalsInfoPath) { data, error in
            TFLLogger.shared.signPostEnd(osLog: TFLClient.loggingHandle, name: "vehicleInfo",identifier: vehicleId)
            guard let data = data else {
                operationQueue.addOperation {
                    completionBlock(nil,error)
                }
                return
            }
            let predictions = try? TFLClient.jsonDecoder.decode([TFLVehicleArrivalInfo].self,from: data)
            operationQueue.addOperation {
                completionBlock(predictions,nil)
            }
        }
    }
    
    public func arrivalsForStopPoint(with identifier: String,
                                     with operationQueue : OperationQueue = OperationQueue.main,
                                     using completionBlock:@escaping (([TFLBusPrediction]?,_ error:Error?) -> ()))  {
        let arivalsPath = "/StopPoint/\(identifier)/Arrivals"
        TFLLogger.shared.signPostStart(osLog: TFLClient.loggingHandle, name: "arrivalsForStopPoint",identifier: identifier)
        tflManager.getDataWithRelativePath(relativePath: arivalsPath) { data, error in
            TFLLogger.shared.signPostEnd(osLog: TFLClient.loggingHandle, name: "arrivalsForStopPoint",identifier: identifier)
            guard let data = data else {
                operationQueue.addOperation {
                    completionBlock(nil,error)
                }
                return
            }
            let predictions = try? TFLClient.jsonDecoder.decode([TFLBusPrediction].self,from: data)
            operationQueue.addOperation {
                completionBlock(predictions,nil)
            }
        }
    }

    public func nearbyBusStops(with coordinate: CLLocationCoordinate2D,
                               radius: Int = 500,
                               with operationQueue : OperationQueue = OperationQueue.main,
                               using completionBlock: (([TFLCDBusStop]?,_ error:Error?) -> ())? = nil)  {
        
        let busStopPath = "/StopPoint"
        let query = "radius=\(radius)&lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&stopTypes=NaptanPublicBusCoachTram&categories=Geo,Direction"
        let context = TFLBusStopStack.sharedDataStack.privateQueueManagedObjectContext
        TFLLogger.shared.signPostStart(osLog: TFLClient.loggingHandle, name: "nearbyBusStops API")
        requestBusStops(with: busStopPath, query: query,context:context, with: backgroundQueue) {stops,error in
            TFLLogger.shared.signPostEnd(osLog: TFLClient.loggingHandle, name: "nearbyBusStops API")
            context.perform {
                if context.hasChanges {
                    _ = try? context.save()
                }
                operationQueue.addOperation {
                    completionBlock?(stops,error)
                }
            }
        }

    }
    #if DATABASEGENERATION
    public func busStops(with page: UInt,
                         with operationQueue : OperationQueue = OperationQueue.main,
                         using completionBlock: @escaping (([TFLCDBusStop]?,_ error:Error?) -> ()))  {
        let busStopPath = "/StopPoint/Mode/bus"
        let query = "page=\(page+1)"
        TFLLogger.shared.signPostStart(osLog: TFLClient.loggingHandle, name: "busStops")
        requestBusStops(with: busStopPath, query: query,context:TFLCoreDataStack.sharedDataStack.privateQueueManagedObjectContext) { busstops, error in
            TFLLogger.shared.signPostEnd(osLog: TFLClient.loggingHandle, name: "busStops")
            operationQueue.addOperation {
                completionBlock(busstops,error)
            }
        }
    }
    #endif
    public func lineStationInfo(for line: String,
                        context: NSManagedObjectContext,
                         with operationQueue : OperationQueue = OperationQueue.main,
                         using completionBlock: ((TFLCDLineInfo?,_ error:Error?) -> ())? = nil)  {
        guard !line.isEmpty else {
            operationQueue.addOperation {
                completionBlock?(nil,TFLClientError.InvalidLine)
            }
            return
        }
        let lineStationPath = "/Line/\(line)/Route/Sequence/all"
        TFLLogger.shared.signPostStart(osLog: TFLClient.loggingHandle, name: "lineStationInfo",identifier: line)
        lineStationInfo(with: lineStationPath, query: "serviceTypes=Regular&excludeCrowding=true", context: context) { lineInfo , error in
            TFLLogger.shared.signPostEnd(osLog: TFLClient.loggingHandle, name: "lineStationInfo",identifier: line)
            operationQueue.addOperation {
                completionBlock?(lineInfo,error)
            }
        }
    }

}

fileprivate extension TFLClient {
    func lineStationInfo(with relativePath: String,
                         query: String,context: NSManagedObjectContext,
                         with operationQueue : OperationQueue = OperationQueue.main,
                         completionBlock: @escaping ((TFLCDLineInfo?,_ error:Error?) -> ()))  {
        tflManager.getDataWithRelativePath(relativePath: relativePath,and: query) {  data, _ in
            if let data = data,let jsonDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
            
                TFLCDLineInfo.lineInfo(with: jsonDict, and: context) { lineInfo in
                    context.perform {
                        try? context.save()
                    }
                    operationQueue.addOperation {
                        completionBlock(lineInfo,nil)
                    }

                }
                
            } else {
                operationQueue.addOperation {
                    completionBlock(nil,TFLClientError.InvalidFormat(data: data))
                }
            }
        }
    }


    func requestBusStops(with relativePath: String,
                                     query: String,context: NSManagedObjectContext,
                                     with operationQueue : OperationQueue = OperationQueue.main,
                                     completionBlock: @escaping (([TFLCDBusStop]?,_ error:Error?) -> ()))  {
        tflManager.getDataWithRelativePath(relativePath: relativePath,and: query) {  [weak self] data, error in
            if let data = data,
                let jsonDict = try? JSONSerialization.jsonObject(with: data as Data
                    , options: JSONSerialization.ReadingOptions(rawValue:0)) as? [String : Any] {
                if let jsonList = jsonDict["stopPoints"] as? [[String: Any]] {
                    self?.stopPoints(from: jsonList, context: context) { stops in
                        operationQueue.addOperation {
                            completionBlock(stops,nil)
                        }
                    }
                }
                else {
                    operationQueue.addOperation {
                         completionBlock(nil,TFLClientError.InvalidFormat(data: data))
                    }
                }
            }
            else {
                operationQueue.addOperation {
                    completionBlock(nil,error)
                }
            }
        }
    }

    func stopPoints(from dictionaryList : [[String: Any]],context: NSManagedObjectContext, using completionBlock : @escaping (_ stopPoints : [TFLCDBusStop]) -> ()) {
        var stops : [TFLCDBusStop] = []
        let group = DispatchGroup()
        dictionaryList.forEach {
            group.enter()
            TFLCDBusStop.busStop(with: $0,and:context) { busStop in
                if let busStop = busStop {
                    stops += [busStop]
                }
                group.leave()
            }
        }
        group.notify(queue: DispatchQueue.global()) {
            completionBlock(stops)
        }
    }
}
