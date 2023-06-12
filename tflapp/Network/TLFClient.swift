
import Foundation
import CoreLocation
import CoreData
import os.signpost

enum TFLClientError : Error {
    case InvalidFormat(data : Data?)
    case InvalidLine
    case InvalidJSON
}

public final class TFLClient {
    static let jsonDecoder = { ()-> JSONDecoder in
        let decoder = JSONDecoder()
        return decoder
    }()
    lazy var tflManager  = TFLRequestManager.shared
    fileprivate let logger : Logger =  {
        let handle = Logger(subsystem: TFLLogger.subsystem, category: TFLLogger.category.api.rawValue)
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
        Task{
            do {
                logger.log("\(#function) vehicleInfo:\(vehicleId)")
                let data = try await tflManager.getDataWithRelativePath(relativePath: vehicleArrivalsInfoPath)
                let predictions = try? TFLClient.jsonDecoder.decode([TFLVehicleArrivalInfo].self,from: data)
                operationQueue.addOperation{
                    completionBlock(predictions,nil)
                }
            }
            catch let error {
                operationQueue.addOperation{
                    completionBlock(nil,error)
                }
            }
        }
    }
    
    public func arrivalsForStopPoint(with identifier: String,
                                     with operationQueue : OperationQueue = OperationQueue.main,
                                     using completionBlock:@escaping (([TFLBusPrediction]?,_ error:Error?) -> ()))  {
        let arivalsPath = "/StopPoint/\(identifier)/Arrivals"
        Task{
            do {
                logger.log("\(#function) arrivalsForStopPoint:\(identifier)")
                let data = try await tflManager.getDataWithRelativePath(relativePath: arivalsPath)
                let predictions = try? TFLClient.jsonDecoder.decode([TFLBusPrediction].self,from: data)
                operationQueue.addOperation{
                    completionBlock(predictions,nil)
                }
            }
            catch let error {
                operationQueue.addOperation{
                    completionBlock(nil,error)
                }
            }
        }
    }

    public func nearbyBusStops(with coordinate: CLLocationCoordinate2D,
                               radius: Int = 500,
                               with operationQueue : OperationQueue = OperationQueue.main,
                               using completionBlock: (([TFLCDBusStop]?,_ error:Error?) -> ())? = nil)  {
        let busStopPath = "/StopPoint"
        let query = "radius=\(radius)&lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&stopTypes=NaptanPublicBusCoachTram&categories=Geo,Direction"

        Task{
            do{
                logger.log("\(#function) \(query)")
                let context = TFLBusStopStack.sharedDataStack.privateQueueManagedObjectContext
                let stops = try await requestBusStops(with: busStopPath, query: query,context:context)
                await context.perform{
                    if context.hasChanges {
                        _ = try? context.save()
                    }
                    operationQueue.addOperation{
                        completionBlock?(stops,nil)
                    }
                }
            }
            catch let error {
                operationQueue.addOperation{
                    completionBlock?(nil,error)
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
            operationQueue.addOperation{
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
            operationQueue.addOperation{
                completionBlock?(nil,TFLClientError.InvalidLine)
            }
            return
        }
        let lineStationPath = "/Line/\(line)/Route/Sequence/all"
        Task {
            do {
                self.logger.log("\(#function) lineStationInfo: \(line)")
                let lineInfo = try await lineStationInfo(with: lineStationPath, query: "serviceTypes=Regular&excludeCrowding=true", context: context)
                operationQueue.addOperation{
                    completionBlock?(lineInfo,nil)
                }
            }
            catch let error {
                completionBlock?(nil,error)
            }
        }
    }

}

fileprivate extension TFLClient {
    func lineStationInfo(with relativePath: String,
                         query: String,context: NSManagedObjectContext) async throws -> TFLCDLineInfo {
        let data = try await tflManager.getDataWithRelativePath(relativePath: relativePath,and: query)
        
        if let jsonDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
            return try await withCheckedThrowingContinuation { continuation in
                TFLCDLineInfo.lineInfo(with: jsonDict, and: context) { lineInfo in
                    guard let lineInfo = lineInfo else {
                        continuation.resume(throwing: TFLClientError.InvalidJSON)
                        return
                    }
                    context.perform {
                        try? context.save()
                    }
                    continuation.resume(returning: lineInfo)
                }
            }
        } else {
            throw TFLClientError.InvalidFormat(data: data)
        }
    }


    func requestBusStops(with relativePath: String,
                                     query: String,context: NSManagedObjectContext) async throws -> [TFLCDBusStop] {
        let data = try await tflManager.getDataWithRelativePath(relativePath: relativePath,and: query)
        if let jsonDict = try JSONSerialization.jsonObject(with: data as Data
                , options: JSONSerialization.ReadingOptions(rawValue:0)) as? [String : Any] {
            if let jsonList = jsonDict["stopPoints"] as? [[String: Any]] {
                return await withCheckedContinuation { continuation in
                    self.stopPoints(from: jsonList, context: context) { stops in
                        continuation.resume(returning: stops)
                    }
                }
            }
            else {
                throw TFLClientError.InvalidFormat(data: data)
            }
        }
        else {
            throw TFLClientError.InvalidJSON
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
