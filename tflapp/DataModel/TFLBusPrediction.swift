import Foundation
import SwiftData


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

public struct TFLBusPrediction : Decodable,Identifiable, CustomStringConvertible {
    enum Mode : String {
        case bus
    }
    enum TFLBusPredictionError : Error {
        case decodingError
        case invalidModeType
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
        case towards = "towards"
        case modeName
    }
    public var description: String {
        "identifier: \(identifier) eta:\(eta) etaInSeconds:\(etaInSeconds)"
    }
    
    let identifier : String
    let timeToLive : Date
    let timeStamp : Date
    let busStopIdentifier : String
    let lineIdentifier : String
    let lineName : String
    let destination : String
    let timeToStation : Int
    let vehicleId : String
    let towards : String
    let eta : String 
    let etaInSeconds : Int
   
    let mode : Mode
    public var id : String {
        return identifier
    }
    
    init(identifier: String, timeToLive: Date,timeStamp: Date, busStopIdentifier: String, lineIdentifier: String, lineName: String, destination: String, timeToStation : Int, vehicleId : String, towards: String, eta: String, etaInSeconds: Int, mode: Mode) {
        self.identifier = identifier
        self.timeToLive = timeToLive
        self.timeStamp = timeStamp
        self.busStopIdentifier = busStopIdentifier
        self.lineIdentifier = lineIdentifier
        self.lineName = lineName
        self.destination = destination
        self.timeToStation = timeToStation
        self.vehicleId = vehicleId
        self.towards = towards
        self.eta = eta
        self.etaInSeconds = etaInSeconds
        self.mode = mode
        
        
    }
    
    public init(from decoder: Decoder) throws {
        func arrivalTime(in secs : Int) -> String {
            let minTitle = "1 \(NSLocalizedString("Common.min", comment: ""))"
            let minsTitle = NSLocalizedString("Common.mins", comment: "")
            
            switch secs {
            case ..<30:
                return NSLocalizedString("Common.due", comment: "")
            case 30..<60:
                return minTitle
            case 60..<(99*60):
                let mins = secs/60
                return mins == 1 ? minTitle : "\(mins) \(minsTitle)"
            default:
                return ""
            }
        }
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
        
        let modeName = try container.decode(String.self, forKey: .modeName)
        guard let modeType = Mode(rawValue: modeName) else {
            throw TFLBusPredictionError.invalidModeType
        }
        mode = modeType
        
        destination = try container.decode(String.self, forKey: .destination)
        timeToStation = try container.decode(Int.self, forKey: .timeToStation)
        vehicleId = try container.decode(String.self, forKey: .vehicleId)
        towards = try container.decode(String.self, forKey: .towards)
        
        let timeOffset = Int(Date() - timeStamp)
        etaInSeconds = Int(timeToStation) - timeOffset
        eta =  arrivalTime(in:etaInSeconds )
    }
    
    func predictionoWithTimestampReducedBy(_ seconds: Int) -> TFLBusPrediction {
        func arrivalTime(in secs : Int) -> String {
            let minTitle = "1 \(NSLocalizedString("Common.min", comment: ""))"
            let minsTitle = NSLocalizedString("Common.mins", comment: "")
            
            switch secs {
            case ..<30:
                return NSLocalizedString("Common.due", comment: "")
            case 30..<60:
                return minTitle
            case 60..<(99*60):
                let mins = secs/60
                return mins == 1 ? minTitle : "\(mins) \(minsTitle)"
            default:
                return ""
            }
        }
        let newTimeToStation = max(timeToStation - seconds,0)
        let newEtaInSeconds = max(etaInSeconds - seconds,0)
        let newEta =  arrivalTime(in:etaInSeconds )
        let new =  TFLBusPrediction(identifier: self.identifier, timeToLive: self.timeToLive, timeStamp: self.timeStamp, busStopIdentifier: self.busStopIdentifier, lineIdentifier: self.lineIdentifier, lineName: self.lineName, destination: self.destination, timeToStation: newTimeToStation, vehicleId: self.vehicleId, towards: self.towards, eta: newEta, etaInSeconds: newEtaInSeconds, mode: mode)
   
        return new
    }
    
}

 extension TFLBusPrediction : Equatable {
    static public func ==(lhs: TFLBusPrediction, rhs: TFLBusPrediction) -> Bool {
        return lhs.etaInSeconds == rhs.etaInSeconds && lhs.lineName == rhs.lineName
    }
}

extension Date {
    static func-(lhs: Self, rhs: Self) -> Double {
        lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }
}
