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
    "timestamp": "2017-06-17T12:36:05Z",
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

    private enum CodingKeys : String,CodingKey {
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
    let identifier : String
    let timeToLive : Date
    let timeStamp : Date
    let busStopIdentifier : String
    let lineIdentifier : String
    let lineName : String
    let destination : String
    let timeToStation : UInt
}
