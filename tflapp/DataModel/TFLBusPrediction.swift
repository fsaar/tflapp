import Foundation



/*
    "$type": "Tfl.Api.Presentation.Entities.Prediction, Tfl.Api.Presentation.Entities",
    "id": "455967472",
    "operationType": 1,
    "vehicleId": "LJ16EWO",
    "naptanId": "490004996U",
    "stationName": "Charles I I Street",
    "lineId": "94",
    "lineName": "94",
    "platformName": "U",
    "direction": "outbound",
    "bearing": "239",
    "destinationNaptanId": "",
    "destinationName": "Piccadilly Circus",
    "timestamp": "2017-06-17T12:36:05.1741351Z",

    "timeToStation": 1246,
    "currentLocation": "",
    "towards": "Oxford Circus",
    "expectedArrival": "2017-06-17T12:56:51Z",
    "timeToLive": "2017-06-17T12:57:21Z",

    "modeName": "bus",
    "timing": {
        "$type": "Tfl.Api.Presentation.Entities.PredictionTiming, Tfl.Api.Presentation.Entities",
        "countdownServerAdjustment": "00:00:00.1952593",
        "source": "2017-06-15T14:08:50.854Z",
        "insert": "2017-06-17T12:35:10.923Z",
        "read": "2017-06-17T12:35:10.923Z",
        "sent": "2017-06-17T12:36:05Z",
        "received": "0001-01-01T00:00:00Z"
     }
 
 */
public struct TFLBusPrediction : Equatable,Codable,CustomStringConvertible {

    enum TFLBusPredictionError : Error {
        case decodingError
    }
    
    static let iso8601Full: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    static let isoDefault: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()
    
    private enum CodingKeys : String,CodingKey {
        case vehicleId = "vehicleId"
        case identifier = "id"
        case timeToLive = "timeToLive"
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
    

    public var description: String {
        let secondsPerMinute : UInt = 60
        let prefix = self.lineName + " towards " + destination
        return prefix + " in " + "\(Int(timeToStation/secondsPerMinute)) minutes [\(timeToStation) secs]\n"
    }
    
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(identifier, forKey: .identifier)
        let ttlString = TFLBusPrediction.isoDefault.string(from: timeToLive)
        try container.encode(ttlString, forKey: .timeToLive)
        let timeStampString = TFLBusPrediction.iso8601Full.string(from: timeStamp)
        try container.encode(timeStampString, forKey: .timeStamp)
        try container.encode(busStopIdentifier, forKey: .busStopIdentifier)
        try container.encode(lineIdentifier, forKey: .lineIdentifier)
        try container.encode(lineName, forKey: .lineName)
        try container.encode(destination, forKey: .destination)
        try container.encode(timeToStation, forKey: .timeToStation)
        try container.encode(vehicleId, forKey: .vehicleId)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let ttlString = try container.decode(String.self, forKey: .timeToLive)
        let timeStampString = try container.decode(String.self, forKey: .timeStamp)
        guard let timeToLiveDate = TFLBusPrediction.isoDefault.date(from: ttlString),
            let timeStampDate =  TFLBusPrediction.iso8601Full.date(from: timeStampString)
            else {
                throw TFLBusPredictionError.decodingError
        }
        identifier = try container.decode(String.self, forKey: .identifier)
        timeToLive = timeToLiveDate
        timeStamp = timeStampDate
        busStopIdentifier = try container.decode(String.self, forKey: .busStopIdentifier)
        lineIdentifier = try container.decode(String.self, forKey: .lineIdentifier)
        lineName = try container.decode(String.self, forKey: .lineName)
        destination = try container.decode(String.self, forKey: .destination)
        timeToStation = try container.decode(UInt.self, forKey: .timeToStation)
        vehicleId = try container.decode(String.self, forKey: .vehicleId)
    }
    
    let identifier : String
    let timeToLive : Date
    let timeStamp : Date
    let busStopIdentifier : String
    let lineIdentifier : String
    let lineName : String
    let destination : String
    let timeToStation : UInt
    let vehicleId : String
}
