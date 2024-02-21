
import Foundation
import CoreLocation
import CoreData
import os.signpost


private struct TFLBusStationWrapper : Decodable {
    let stopPoints : [TFLBusStation]
}


enum TFLClientError : Error {
    case InvalidFormat(data : Data?)
    case InvalidLine
    case InvalidJSON
}

final class TFLClient {
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
    
//    public func vehicleArrivalsInfo(with vehicleId: String,
//                                     with operationQueue : OperationQueue = OperationQueue.main,
//                                     using completionBlock:@escaping (([TFLVehicleArrivalInfo]?,_ error:Error?) -> ()))  {
//        let vehicleArrivalsInfoPath = "/Vehicle/\(vehicleId)/Arrivals"
//        Task{
//            do {
//                logger.log("\(#function) vehicleInfo:\(vehicleId)")
//                let data = try await tflManager.getDataWithRelativePath(relativePath: vehicleArrivalsInfoPath)
//                let predictions = try? TFLClient.jsonDecoder.decode([TFLVehicleArrivalInfo].self,from: data)
//                operationQueue.addOperation{
//                    completionBlock(predictions,nil)
//                }
//            }
//            catch let error {
//                operationQueue.addOperation{
//                    completionBlock(nil,error)
//                }
//            }
//        }
//    }
    
    func arrivalsForStopPoint(with identifier: String) async throws -> [TFLBusPrediction] {
        
        let arivalsPath = "/StopPoint/\(identifier)/Arrivals"
        logger.log("\(#function) identifier:\(identifier)")
        let data = try await tflManager.getDataWithRelativePath(relativePath: arivalsPath)
        let predictions = try TFLClient.jsonDecoder.decode([TFLBusPrediction].self,from: data)
        return predictions
    }

    func nearbyBusStops(with coordinate: CLLocationCoordinate2D,
                        radius: Int = 500) async -> [TFLBusStation] {
        let busStopPath = "/StopPoint"
        let query = "radius=\(radius)&lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&stopTypes=NaptanPublicBusCoachTram&categories=Geo,Direction"
        
        logger.log("\(#function) \(query)")
        
        let stops = try? await requestBusStops(with: busStopPath, query: query)
        return stops ?? []
    }
  
    func busStops(with page: UInt) async throws -> [TFLBusStation] {
        let busStopPath = "/StopPoint/Mode/bus"
        let query = "page=\(page+1)"
        logger.log("\(#function) start:\(page)")
        let busstops = try await requestBusStops(with: busStopPath, query: query)
        logger.log("\(#function) stop:\(page)")
        return busstops
    }
    
    func lineStationInfo(for line: String) async throws -> TFLLineInfo {
        guard !line.isEmpty else {
            throw TFLClientError.InvalidLine
        }
        let lineStationPath = "/Line/\(line)/Route/Sequence/all"
        logger.log("\(#function) lineStationInfo:\(line)")
        let data = try await tflManager.getDataWithRelativePath(relativePath:lineStationPath ,and: "serviceTypes=Regular&excludeCrowding=true")
        let lineInfo = try JSONDecoder().decode(TFLLineInfo.self, from: data)
        return lineInfo
    }
}

fileprivate extension TFLClient {
    func requestBusStops(with relativePath: String,
                                     query: String) async throws -> [TFLBusStation] {
        let data = try await tflManager.getDataWithRelativePath(relativePath: relativePath,and: query)
        let wrapper = try JSONDecoder().decode(TFLBusStationWrapper.self, from: data)
        return wrapper.stopPoints
    }
}
