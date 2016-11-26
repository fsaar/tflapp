import Foundation

public struct TFLBusStopArrivalsInfo : CustomDebugStringConvertible,Hashable {
    public var debugDescription: String {
        return busStop.debugDescription + "\(busStopDistance) arrivals:\(arrivals.count)"
    }
    let busStop : TFLCDBusStop
    let busStopDistance : Double
    let arrivals : [TFLBusPrediction]
    
    public var hashValue: Int {
        return self.busStop.identifier.hashValue
    }
    
    public static func ==(lhs: TFLBusStopArrivalsInfo, rhs: TFLBusStopArrivalsInfo) -> Bool {
        return lhs.busStop.identifier == rhs.busStop.identifier
        
    }
    
    public static func compare(lhs: TFLBusStopArrivalsInfo, rhs: TFLBusStopArrivalsInfo) -> Bool  {
        return lhs.busStopDistance <= rhs.busStopDistance
    }
}

