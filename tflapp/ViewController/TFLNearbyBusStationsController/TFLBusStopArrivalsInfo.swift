import Foundation
import MapKit

public struct TFLBusStopArrivalsInfo : Hashable {
    public struct TFLContextFreeBusStopInfo {
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
