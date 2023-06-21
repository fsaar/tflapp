import Foundation
import MapKit

extension Collection where Element == TFLBusStopArrivalsInfo {
    
    // Debug method to write down current list of TFLBusStopArrivalsInfo down to disk
    // - Parameters:
    //      - tag: string to further uniqify filename
    func log(with tag: String = "") {
       
        guard  let infos = self as? [TFLBusStopArrivalsInfo],let data = try? JSONEncoder().encode(infos) else {
            return
        }
        let date = Date()
        let dateFormatter = ISO8601DateFormatter()
        let dateString = dateFormatter.string(from: date)
        let fileName = tag.isEmpty ? "\(dateString).dat" : "\(dateString)_\(tag).dat"
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let path = "\(documentsPath)/\(fileName)"
        let url = URL(fileURLWithPath: path)
        try? data.write(to: url, options: Data.WritingOptions.atomicWrite)
    }
    
    // Method to sort by property busStopDistance to make code more readable
    // - Returns:
    //      - arrivalinfos sorted by busStopDistance
    func sortedByBusStopDistance() -> [Element] {
        return self.sorted{ $0.busStopDistance < $1.busStopDistance }
    }
    
    // merges new arrival infos with old infos
    // old infos will only be used if arrivals in new list is empty
    // Data in newInfo determines what will be returned. Oldinfo only used to fill blank data
    // - Parameters:
    //      - newInfo: new arrivalInfos
    // - Returns:
    //      - merged arrivalinfos
    func mergedArrivalsInfo(_ newInfo : [TFLBusStopArrivalsInfo]) ->  [TFLBusStopArrivalsInfo] {
        let dict = Dictionary(uniqueKeysWithValues: self.map{ ($0.identifier,$0) })
        let mergedInfo : [TFLBusStopArrivalsInfo] = newInfo.map{  info in
            guard info.arrivals.isEmpty else {
                return info
            }
            return dict[info.identifier] ?? info
        }
        return mergedInfo
    }
    
    // merges new arrival infos with current arrival infos
    // updated infos will only be used if available. New infos that are not in old info will be disregarded
    // Returns info list where outdata data is updated by new data in newInfo
    //
    // - Parameters:
    //      - newInfo: new arrivalInfos
    // - Returns:
    //      - updated arrivalinfos
    func mergedUpdatedArrivalsInfo(_ newInfo : [TFLBusStopArrivalsInfo]) ->  [TFLBusStopArrivalsInfo] {
        let oldIdentifiers = self.map{ $0.identifier }
        let newIdentifiers = newInfo.compactMap{ !$0.arrivals.isEmpty ? $0.identifier : nil }
        let updatedIdentifiers = Set(oldIdentifiers).intersection(newIdentifiers)
        let newDict = Dictionary(uniqueKeysWithValues: newInfo.map{ ($0.identifier,$0) })
        var oldDict = Dictionary(uniqueKeysWithValues: self.map{ ($0.identifier,$0) })
        updatedIdentifiers.forEach { identifier in
            oldDict[identifier] = newDict[identifier]
        }
        
        let updatedInfo = oldDict.map{ $0.value }
        return updatedInfo.sortedByBusStopDistance()
    }
    
}



public struct TFLBusStopArrivalsInfo : Hashable,CustomStringConvertible,Identifiable {
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
    
    public var description : String {
        let lines = arrivals.sorted{ $0.timeStamp < $1.timeStamp }.map{ $0.lineName }.joined(separator: " < ")
        let desc =  """
                        [\(busStop.stopLetter ?? "")] \(busStop.name ) [\(identifier)]\n
                        \(lines)
                    """
        return desc
    }
    public var id : String {
        return identifier
    }
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
        let distance = location.distance(from: busStop.coord.location)
        self.busStopDistance = distance
        self.busStop = busStop
        self.arrivals = Set(arrivals).sorted{ $0.timeToStation  < $1.timeToStation }
    }

     init(busStop: TFLCDBusStop, location: CLLocation, arrivals: [TFLBusPrediction]) {
        let busStopInfo = TFLContextFreeBusStopInfo(with: busStop)
        self.init(busStop: busStopInfo, location: location, arrivals: arrivals)
    }
    
    func arrivalInfo(with location : CLLocation) -> TFLBusStopArrivalsInfo {
        return TFLBusStopArrivalsInfo(busStop: self.busStop, location: location, arrivals: self.arrivals)
    }
    
    func liveArrivals(with referenceDate: Date = Date()) -> [TFLBusPrediction]  {
        let referenceTime = referenceDate.timeIntervalSinceReferenceDate
        let filteredArrivals = arrivals.filter{ $0.timeToLive.timeIntervalSinceReferenceDate >= referenceTime }
        return filteredArrivals
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
