import Foundation

public struct TFLBusStopArrivalsInfo : CustomDebugStringConvertible {
    public var debugDescription: String {
        return busStop.debugDescription + "\(busStopDistance) arrivals:\(arrivals.count)"
    }
    let busStop : TFLCDBusStop
    let busStopDistance : Double
    let arrivals : [TFLBusPrediction]
}

