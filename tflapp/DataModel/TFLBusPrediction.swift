import Foundation

public struct TFLBusPrediction : CustomDebugStringConvertible,Equatable {
    static private let iso8601DateFormatter = ISO8601DateFormatter()
    static private let timeFormatter : DateFormatter = { () -> (DateFormatter) in
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.calendar = Calendar(identifier: .iso8601)
        return formatter
    }()
    

    private enum Identifiers : String {
        case identifier = "id"
        case ttl = "timeToLive"
        case timeStamp = "timestamp"
        case busStopIdentifier = "naptanId"
        case lineIdentifier = "lineId"
        case lineName = "lineName"
        case destination = "destinationName"
        case timeToStation = "timeToStation"
    }
    public static func ==(lhs: TFLBusPrediction,rhs: TFLBusPrediction) -> (Bool) {
        return lhs.identifier == rhs.identifier
    }
    
    public var debugDescription: String {
        let secondsPerMinute : UInt = 60
        let prefix = self.lineName + " towards " + destination
        return prefix + " in " + "\(Int(timeToStation/secondsPerMinute)) minutes [\(timeToStation) secs]\n"
    }
    let identifier : String
    let ttlSinceReferenceDate : TimeInterval
    let timeStampSinceReferenceDate : TimeInterval
    let busStopIdentifier : String
    let lineIdentifier : String
    let lineName : String
    let destination : String
    let timeToStation : UInt
    
    init?(with dictionary: [String: Any]) {
        guard let identifier = dictionary[Identifiers.identifier.rawValue] as? String,let timeToStation = dictionary[Identifiers.timeToStation.rawValue]  as? UInt else {
            return nil
        }
        self.identifier = identifier
        let ttl = dictionary[Identifiers.ttl.rawValue] as? String ?? ""
        let ttlDate = TFLBusPrediction.timeFormatter.date(from: ttl)
        self.ttlSinceReferenceDate = ttlDate?.timeIntervalSinceReferenceDate ?? 0
        let timeStamp = dictionary[Identifiers.timeStamp.rawValue] as? String ?? ""
        let timeStampDate = TFLBusPrediction.iso8601DateFormatter.date(from: timeStamp)
        self.timeStampSinceReferenceDate = timeStampDate?.timeIntervalSinceReferenceDate ?? 0
        self.busStopIdentifier = dictionary[Identifiers.busStopIdentifier.rawValue] as? String ?? ""
        self.lineIdentifier = dictionary[Identifiers.lineIdentifier.rawValue] as? String ?? ""
        self.lineName = dictionary[Identifiers.lineName.rawValue] as? String ?? ""
        self.destination = dictionary[Identifiers.destination.rawValue] as? String ?? ""
        self.timeToStation = timeToStation
    }
}
