import Foundation

public struct TFLBusStopArrivalsInfo : CustomDebugStringConvertible,Hashable {
    public var debugDescription: String {
        return busStop.debugDescription + "\(busStopDistance) arrivals:\(arrivals.count)"
    }
    let busStop : TFLCDBusStop
    let busStopDistance : Double
    let arrivals : [TFLBusPrediction]
    var identifier : String {
        return self.busStop.identifier
    }
    var debugInfo : String {
        return "\(identifier),\(busStopDistance)"
    }
    
    public var hashValue: Int {
        return self.identifier.hashValue
    }
    
    public static func ==(lhs: TFLBusStopArrivalsInfo, rhs: TFLBusStopArrivalsInfo) -> Bool {
        return lhs.identifier == rhs.identifier
        
    }
    
    public static func compare(lhs: TFLBusStopArrivalsInfo, rhs: TFLBusStopArrivalsInfo) -> Bool  {
        return lhs.busStopDistance <= rhs.busStopDistance
    }
    
    init(busStop: TFLCDBusStop, busStopDistance: Double, arrivals: [TFLBusPrediction]) {
        self.busStop = busStop
        self.busStopDistance = busStopDistance
        self.arrivals = arrivals.sorted { $0.timeToStation  < $1.timeToStation  }
    }
}

