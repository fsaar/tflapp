
import Foundation
import CoreLocation
import CoreData
import os.signpost

enum TFLClientError : Error {
    case InvalidFormat(data : Data?)
    case InvalidLine
    case InvalidParameter
}

public final class TFLClient {
    
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
    
    public func vehicleArrivalsInfo(with vehicleId: String) async throws -> [TFLVehicleArrivalInfo] {
        defer {
            TFLLogger.shared.signPostEnd(osLog: TFLClient.loggingHandle, name: "vehicleInfo",identifier: vehicleId)
        }
        let vehicleArrivalsInfoPath = "/Vehicle/\(vehicleId)/Arrivals"
        TFLLogger.shared.signPostStart(osLog: TFLClient.loggingHandle, name: "vehicleInfo",identifier: vehicleId)
        let data = try await tflManager.getDataWithRelativePath(relativePath: vehicleArrivalsInfoPath)
        let predictions = try JSONDecoder().decode([TFLVehicleArrivalInfo].self,from: data)
        return predictions
    }
    
    public func arrivalsForStopPoint(with identifier: String) async -> [TFLBusPrediction] {
                                 
        let arivalsPath = "/StopPoint/\(identifier)/Arrivals"
        TFLLogger.shared.signPostStart(osLog: TFLClient.loggingHandle, name: "arrivalsForStopPoint",identifier: identifier)
        let data = try? await  tflManager.getDataWithRelativePath(relativePath: arivalsPath)
        TFLLogger.shared.signPostEnd(osLog: TFLClient.loggingHandle, name: "arrivalsForStopPoint",identifier: identifier)
        guard let data = data else {
            return []
        }
        let predictions = (try? JSONDecoder().decode([TFLBusPrediction].self,from: data)) ?? []
        return predictions
    }

    public func nearbyBusStops(with coordinate: CLLocationCoordinate2D,radius: Int = 500) async  -> [TFLCDBusStop]  {
        defer {
            TFLLogger.shared.signPostEnd(osLog: TFLClient.loggingHandle, name: "nearbyBusStops API")
        }
        let busStopPath = "/StopPoint"
        let query = "radius=\(radius)&lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&stopTypes=NaptanPublicBusCoachTram&categories=Geo,Direction"
        TFLLogger.shared.signPostStart(osLog: TFLClient.loggingHandle, name: "nearbyBusStops API")
        let context = TFLBusStopStack.sharedDataStack.privateQueueManagedObjectContext
        let stops = (try? await requestBusStops(with: busStopPath, query: query,context:context)) ?? []
        Task.detached(priority:.background) {
            context.perform {
                _ = try? context.save()
            }
        }
        return stops
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
                        context: NSManagedObjectContext) async throws -> TFLCDLineInfo {
        defer {
            TFLLogger.shared.signPostEnd(osLog: TFLClient.loggingHandle, name: "lineStationInfo",identifier: line)
        }
        guard !line.isEmpty else {
            throw TFLClientError.InvalidParameter
        }
        let lineStationPath = "/Line/\(line)/Route/Sequence/all"
        TFLLogger.shared.signPostStart(osLog: TFLClient.loggingHandle, name: "lineStationInfo",identifier: line)
        let lineInfo = try await lineStationInfo(with: lineStationPath, query: "serviceTypes=Regular&excludeCrowding=true", context: context)
        return lineInfo
    }

}

fileprivate extension TFLClient {
    func lineStationInfo(with relativePath: String,
                         query: String,context: NSManagedObjectContext) async throws -> TFLCDLineInfo {
        let data = try await tflManager.getDataWithRelativePath(relativePath: relativePath,and: query)
        guard let jsonDict = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]  else {
            throw TFLClientError.InvalidFormat(data: data)
        }
          
        return try await withCheckedThrowingContinuation { continuation in
            TFLCDLineInfo.lineInfo(with: jsonDict, and: context) { lineInfo in
                guard let lineInfo = lineInfo else {
                    continuation.resume(throwing: TFLClientError.InvalidFormat(data: data))
                    return
                }
                context.perform {
                    _ = try? context.save()
                    continuation.resume(returning: lineInfo)
                }
            }
        }
    }


    func requestBusStops(with relativePath: String,query: String,context: NSManagedObjectContext) async throws -> [TFLCDBusStop] {
        let data =  try await tflManager.getDataWithRelativePath(relativePath: relativePath,and: query)
        guard let jsonDict = try JSONSerialization.jsonObject(with: data as Data, options: []) as? [String : Any],
              let jsonList = jsonDict["stopPoints"] as? [[String: Any]] else {
                  throw  TFLClientError.InvalidFormat(data: data)
        }
        return await  self.stopPoints(from: jsonList, context: context)
    }

    func stopPoints(from dictionaryList : [[String: Any]],context: NSManagedObjectContext) async -> [TFLCDBusStop] {
        var stops : [TFLCDBusStop?] = []
        
        await withTaskGroup(of: TFLCDBusStop?.self) { group in
            dictionaryList.forEach { dict in
                group.addTask(priority: .high) {
                    return await withCheckedContinuation { continuation in
                        TFLCDBusStop.busStop(with: dict,and:context) { busStop in
                            continuation.resume(returning: busStop)
                        }
                    }
                   
                }
            }
            
            for await stop in group  {
                stops += [stop]
            }
        }
        return stops.compactMap { $0 }
        
    }
}
