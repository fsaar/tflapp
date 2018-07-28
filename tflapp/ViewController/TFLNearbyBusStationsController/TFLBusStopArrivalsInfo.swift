import Foundation
import MapKit

extension Collection where Element == TFLBusStopArrivalsInfo {
    func sortedByBusStopDistance() -> [Element] {
        return self.sorted { $0.busStopDistance < $1.busStopDistance }
    }
}

public struct TFLBusStopArrivalsInfo : Hashable {
    public struct TFLContextFreeBusStopInfo  {
        let identifier: String
        fileprivate(set) var stopLetter : String?
        fileprivate(set) var towards : String?
        let name : String
        let coord : CLLocationCoordinate2D
        
        init (with busStop : TFLCDBusStop) {
            coord = CLLocationCoordinate2DMake(busStop.lat, busStop.long)
            stopLetter = busStop.stopLetter
            towards = busStop.towards
            name = busStop.name
            identifier = busStop.identifier
        }
        init(identifier : String, stopLetter : String?, towards: String?, name : String, coord : CLLocationCoordinate2D) {
            self.identifier = identifier
            self.stopLetter = stopLetter
            self.towards = towards
            self.name = name
            self.coord = coord
        }
    }
    
    let busStop : TFLContextFreeBusStopInfo
    
    let busStopDistance : Double
    let arrivals : [TFLBusPrediction]
    
   
    
    var identifier : String
    {
        return self.busStop.identifier
    }
    var debugInfo : String {
        return "\(identifier),\(busStopDistance)"
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.identifier)
    }

    public static func ==(lhs: TFLBusStopArrivalsInfo, rhs: TFLBusStopArrivalsInfo) -> Bool {
        return lhs.identifier == rhs.identifier

    }

    public static func compare(lhs: TFLBusStopArrivalsInfo, rhs: TFLBusStopArrivalsInfo) -> Bool  {
        return lhs.busStopDistance <= rhs.busStopDistance
    }
    
    init(busStop: TFLContextFreeBusStopInfo, location: CLLocation, arrivals: [TFLBusPrediction]) {
        let busStopLocation =  CLLocation(latitude: busStop.coord.latitude, longitude: busStop.coord.longitude)
        let distance = location.distance(from: busStopLocation)
        self.busStopDistance = distance
        self.busStop = busStop
        self.arrivals = arrivals.sorted { $0.timeToStation  < $1.timeToStation }
    }

     init(busStop: TFLCDBusStop, location: CLLocation, arrivals: [TFLBusPrediction]) {
        let busStopLocation =  CLLocation(latitude: busStop.coord.latitude, longitude: busStop.coord.longitude)
        let distance = location.distance(from: busStopLocation)
        self.busStopDistance = distance
        self.busStop = TFLContextFreeBusStopInfo(with: busStop)
        self.arrivals = arrivals.sorted { $0.timeToStation  < $1.timeToStation }
    }
    
    func arrivalInfo(with location : CLLocation) -> TFLBusStopArrivalsInfo {
        return TFLBusStopArrivalsInfo(busStop: self.busStop, location: location, arrivals: self.arrivals)
    }
}

extension TFLBusStopArrivalsInfo : Codable {
    enum CodingKeys: String, CodingKey {
        case busStop = "busStop"
        case busStopDistance = "busStopDistance"
        case arrivals = "arrivals"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        busStopDistance = try  container.decode(Double.self, forKey: .busStopDistance)
        busStop = try  container.decode(TFLContextFreeBusStopInfo.self, forKey: .busStop)
        arrivals = try  container.decode([TFLBusPrediction].self, forKey: .arrivals)
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(busStopDistance, forKey: .busStopDistance)
        try container.encode(busStop, forKey: .busStop)
        try container.encode(arrivals, forKey: .arrivals)
    }
}


extension TFLBusStopArrivalsInfo.TFLContextFreeBusStopInfo : Codable {
    enum CodingKeys: String, CodingKey {
        case identifier = "identifier"
        case stopLetter = "stopLetter"
        case name = "name"
        case towards = "towards"
        case coord_lat = "coord_lat"
        case coord_long = "coord_long"
    }
  
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let coord_lat = try container.decode(Double.self, forKey: .coord_lat)
        let coord_long = try  container.decode(Double.self, forKey: .coord_long)
        coord = CLLocationCoordinate2D(latitude: coord_lat, longitude: coord_long)
        name = try  container.decode(String.self, forKey: .name)
        towards = try  container.decodeIfPresent(String.self, forKey: .towards)
        stopLetter = try  container.decodeIfPresent(String.self, forKey: .stopLetter)
        identifier = try  container.decode(String.self, forKey: .identifier)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(coord.latitude, forKey: .coord_lat)
        try container.encode(coord.longitude, forKey: .coord_long)
        try container.encode(name, forKey: .name)
        try container.encode(identifier, forKey: .identifier)
        try container.encodeIfPresent(stopLetter, forKey: .stopLetter)
        try container.encodeIfPresent(towards, forKey: .towards)
    }
}
