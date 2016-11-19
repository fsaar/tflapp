//
//  TFLPrediction.swift
//  tflapp
//
import Foundation

public struct TFLBusPrediction : CustomDebugStringConvertible,Equatable {
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
        let prefix = self.lineName + " towards " + destination
        guard let timeToStation = timeToStation else {
            return prefix + "\n"
        }
        return prefix + " in " + "\(Int(timeToStation/60)) minutes [\(timeToStation) secs]\n"
    }
    let identifier : String
    let ttl : String
    let timeStamp : String
    let busStopIdentifier : String
    let lineIdentifier : String
    let lineName : String
    let destination : String
    let timeToStation : UInt?
    
    init?(with dictionary: [String: Any]) {
        guard let identifier = dictionary[Identifiers.identifier.rawValue] as? String else {
            return nil
        }
        self.identifier = identifier
        self.ttl = dictionary[Identifiers.ttl.rawValue] as? String ?? ""
        self.timeStamp = dictionary[Identifiers.timeStamp.rawValue] as? String ?? ""
        self.busStopIdentifier = dictionary[Identifiers.busStopIdentifier.rawValue] as? String ?? ""
        self.lineIdentifier = dictionary[Identifiers.lineIdentifier.rawValue] as? String ?? ""
        self.lineName = dictionary[Identifiers.lineName.rawValue] as? String ?? ""
        self.destination = dictionary[Identifiers.destination.rawValue] as? String ?? ""
        self.timeToStation = dictionary[Identifiers.timeToStation.rawValue] as? UInt
    }
}
