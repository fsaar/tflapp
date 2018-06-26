
import Foundation
import CoreLocation
import CoreData

enum TFLClientError : Error {
    case InvalidFormat(data : Data?)
    case InvalidLine
}

public final class TFLClient {
    static let jsonDecoder = { ()-> JSONDecoder in
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    lazy var tflManager  = TFLRequestManager.shared

    public func arrivalsForStopPoint(with identifier: String,
                                     with operationQueue : OperationQueue = OperationQueue.main,
                                     using completionBlock:@escaping (([TFLBusPrediction]?,_ error:Error?) -> ()))  {
        let arivalsPath = "/StopPoint/\(identifier)/Arrivals"
        tflManager.getDataWithRelativePath(relativePath: arivalsPath) { data, error in
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
                               with operationQueue : OperationQueue = OperationQueue.main,
                               using completionBlock: @escaping (([TFLCDBusStop]?,_ error:Error?) -> ()))  {
        let busStopPath = "/StopPoint"
        let query = "lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&stopTypes=NaptanPublicBusCoachTram&categories=Geo"
        let context = TFLBusStopStack.sharedDataStack.privateQueueManagedObjectContext
        let queue = OperationQueue()
        queue.qualityOfService = QualityOfService.userInitiated
        requestBusStops(with: busStopPath, query: query,context:context, with: queue) {stops,error in
            context.perform {
                if context.hasChanges {
                    _ = try? context.save()
                }
                operationQueue.addOperation({
                    completionBlock(stops,error)
                })
            }
        }

    }

    public func busStops(with page: UInt,
                         with operationQueue : OperationQueue = OperationQueue.main,
                         using completionBlock: @escaping (([TFLCDBusStop]?,_ error:Error?) -> ()))  {
        let busStopPath = "/StopPoint/Mode/bus"
        let query = "page=\(page+1)"
        requestBusStops(with: busStopPath, query: query,context:TFLCoreDataStack.sharedDataStack.privateQueueManagedObjectContext) { busstops, error in
            operationQueue.addOperation({
                completionBlock(busstops,error)
            })
        }
    }

    public func lineStationInfo(for line: String,
                         with operationQueue : OperationQueue = OperationQueue.main,
                         using completionBlock: @escaping ((TFLCDLineInfo?,_ error:Error?) -> ()))  {
        guard !line.isEmpty else {
            operationQueue.addOperation {
                completionBlock(nil,TFLClientError.InvalidLine)
            }
            return
        }
        let lineStationPath = "/Line/\(line)/Route/Sequence/all"
        lineStationInfo(with: lineStationPath, query: "serviceTypes=Regular&excludeCrowding=true", context: TFLCoreDataStack.sharedDataStack.privateQueueManagedObjectContext) { lineInfo , error in
            operationQueue.addOperation({
                completionBlock(lineInfo,error)
            })
        }
    }

}

fileprivate extension TFLClient {
    func lineStationInfo(with relativePath: String,
                         query: String,context: NSManagedObjectContext,
                         with operationQueue : OperationQueue = OperationQueue.main,
                         completionBlock: @escaping ((TFLCDLineInfo?,_ error:Error?) -> ()))  {
        tflManager.getDataWithRelativePath(relativePath: relativePath,and: query) {  data, error in
            if let data = data,let jsonDict = try? JSONSerialization.jsonObject(with: data as Data
                , options: JSONSerialization.ReadingOptions(rawValue:0)) as? [String : Any] {
                if let jsonDict = jsonDict {
                    TFLCDLineInfo.lineInfo(with: jsonDict, and: context) { lineInfo in
                        operationQueue.addOperation {
                            completionBlock(lineInfo,nil)
                        }

                    }
                } else {
                    operationQueue.addOperation({
                        completionBlock(nil,TFLClientError.InvalidFormat(data: data))
                    })
                }
            } else {
                operationQueue.addOperation({
                    completionBlock(nil,TFLClientError.InvalidFormat(data: data))
                })
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
                if let jsonList = jsonDict?["stopPoints"] as? [[String: Any]] {
                    self?.stopPoints(from: jsonList, context: context) { stops in
                        operationQueue.addOperation({
                            completionBlock(stops,nil)
                        })
                    }
                }
                else {
                    operationQueue.addOperation({
                         completionBlock(nil,TFLClientError.InvalidFormat(data: data))
                    })
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

