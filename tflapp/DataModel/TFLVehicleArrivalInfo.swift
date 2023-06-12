import Foundation



/*
 {
     "$type": "Tfl.Api.Presentation.Entities.Prediction, Tfl.Api.Presentation.Entities",
     "id": "-1497880102",
     "operationType": 1,
     "vehicleId": "LJ16EWO",
     "naptanId": "490000144A",
     "stationName": "Marble Arch / Bayswater Road",
     "lineId": "94",
     "lineName": "94",
     "platformName": "A",
     "direction": "inbound",
     "bearing": "258",
     "destinationNaptanId": "",
     "destinationName": "Acton Green",
     "timestamp": "2018-12-09T22:31:14.4495417Z",
     "timeToStation": 100,
     "currentLocation": "",
     "towards": "Notting Hill Gate",
     "expectedArrival": "2018-12-09T22:32:54Z",
     "timeToLive": "2018-12-09T22:33:24Z",
     "modeName": "bus",
     "timing": {
         "$type": "Tfl.Api.Presentation.Entities.PredictionTiming, Tfl.Api.Presentation.Entities",
         "countdownServerAdjustment": "-00:00:16.0320740",
         "source": "2018-12-09T09:20:50.08Z",
         "insert": "2018-12-09T22:30:54.592Z",
         "read": "2018-12-09T22:30:38.553Z",
         "sent": "2018-12-09T22:31:14Z",
         "received": "0001-01-01T00:00:00Z"
    }
 },
 
 */

extension Array where Element == TFLVehicleArrivalInfo {
    
    func info(with naptandID : String) -> TFLVehicleArrivalInfo? {
        let identifiers = self.map{ $0.busStopIdentifier }
        guard let index = identifiers.firstIndex(of:naptandID) else {
            return nil
        }
        return self[index]
    }
}

public struct TFLVehicleArrivalInfo : CustomStringConvertible {

    enum TFLBusPredictionError : Error {
        case decodingError
    }
    
    private enum CodingKeys : String,CodingKey {
        case vehicleId = "vehicleId"
        case busStopIdentifier = "naptanId"
        case direction = "direction"
        case towards = "towards"
        case timeToLive = "timeToLive"
        case expectedArrival = "expectedArrival"
        case currentLocation = "currentLocation"
        case timeToStation = "timeToStation"
        case platformName = "platformName"
        case stationName = "stationName"
    }
    
    static let isoDefault: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        return formatter
    }()
    
    public var description: String {
        return "\(busStopIdentifier) \(stationName): \(timeToStation) [\(direction),\(currentLocation)]"
    }
    
    let vehicleId : String
    let busStopIdentifier : String
    let direction : String
    let towards : String
    let timeToLive : Date
    let expectedArrival : Date
    let currentLocation : String
    let timeToStation : UInt
    let platformName : String
    let stationName : String

}

extension TFLVehicleArrivalInfo : Equatable {
    
    public static func ==(lhs: TFLVehicleArrivalInfo,rhs: TFLVehicleArrivalInfo) -> (Bool) {
        return lhs.vehicleId == rhs.vehicleId &&
            lhs.busStopIdentifier  == rhs.busStopIdentifier &&
            lhs.towards == rhs.towards &&
            lhs.platformName == rhs.platformName
    }
}

extension TFLVehicleArrivalInfo : Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(vehicleId)
        hasher.combine(busStopIdentifier)
        hasher.combine(towards)
        hasher.combine(platformName)
    }
    
}


extension TFLVehicleArrivalInfo : Codable {
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(vehicleId, forKey: .vehicleId)
        try container.encode(busStopIdentifier, forKey: .busStopIdentifier)
        try container.encode(direction, forKey: .direction)
        try container.encode(towards, forKey: .towards)
        let ttlString = TFLBusPrediction.isoDefault.string(from: timeToLive)
        try container.encode(ttlString, forKey: .timeToLive)
        let expectedArrivalString = TFLBusPrediction.isoDefault.string(from: expectedArrival)
        try container.encode(expectedArrivalString, forKey: .expectedArrival)
        try container.encode(currentLocation, forKey: .currentLocation)
        try container.encode(timeToStation, forKey: .timeToStation)
        try container.encode(platformName, forKey: .platformName)
        try container.encode(stationName, forKey: .stationName)
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let ttlString = try container.decode(String.self, forKey: .timeToLive)
        let expectedArrivalString = try container.decode(String.self, forKey: .expectedArrival)
        guard let timeToLiveDate = TFLVehicleArrivalInfo.isoDefault.date(from: ttlString),
            let expectedArrivalDate =  TFLVehicleArrivalInfo.isoDefault.date(from: expectedArrivalString)
            else {
                throw TFLBusPredictionError.decodingError
        }
        vehicleId = try container.decode(String.self, forKey: .vehicleId)
        busStopIdentifier = try container.decode(String.self, forKey: .busStopIdentifier)
        direction = try container.decode(String.self, forKey: .direction)
        towards = try container.decode(String.self, forKey: .towards)
        timeToLive = timeToLiveDate
        expectedArrival = expectedArrivalDate
        currentLocation = try container.decode(String.self, forKey: .currentLocation)
        timeToStation = try container.decode(UInt.self, forKey: .timeToStation)
        platformName = try container.decode(String.self, forKey: .platformName)
        stationName = try container.decode(String.self, forKey: .stationName)
    }
    
}
