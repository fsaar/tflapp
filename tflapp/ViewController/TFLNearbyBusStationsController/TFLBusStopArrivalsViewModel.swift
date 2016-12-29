import Foundation
import MapKit

public struct TFLBusStopArrivalsViewModel :CustomDebugStringConvertible,Hashable {
    public struct LinePredictionViewModel :CustomDebugStringConvertible,Hashable {
        let line : String
        let eta : String
        let identifier : String
        let timeToStation : Int

        init(with busPrediction: TFLBusPrediction,using referenceTime : TimeInterval) {
            
            func arrivalTime(in secs : Int) -> String {
                var timeString = ""
                
                switch secs {
                case Int.min..<30:
                    timeString = NSLocalizedString("TFLBusStopArrivalsViewModel.due", comment: "")
                case 30..<90:
                    timeString = "1 " + NSLocalizedString("TFLBusStopArrivalsViewModel.min", comment: "")
                case 90..<5940:
                    let mins = secs/60
                    let localizedString = mins == 1 ? "TFLBusStopArrivalsViewModel.min" : "TFLBusStopArrivalsViewModel.mins"
                    timeString = "\(mins) " + NSLocalizedString(localizedString, comment: "")
                default:
                    timeString = ""
                }
                return timeString
            }
            let timeOffset = Int(referenceTime - busPrediction.timeStampSinceReferenceDate)
            self.identifier = busPrediction.identifier
            self.line = busPrediction.lineName
            self.timeToStation = Int(busPrediction.timeToStation)
            self.eta =  arrivalTime(in: Int(timeToStation) - timeOffset )

        }
        public static func ==(lhs: LinePredictionViewModel,rhs :LinePredictionViewModel) -> (Bool) {
            return lhs.identifier == rhs.identifier
        }
        
        public static func compare(lhs: LinePredictionViewModel, rhs: LinePredictionViewModel) -> Bool {
            return lhs.timeToStation <= rhs.timeToStation
        }
        public var debugDescription: String {
            return "\n\(line) [\(identifier)]: \(eta)"
        }
        public var hashValue: Int {
            return self.identifier.hashValue
        }


        
    }
    public static func ==(lhs: TFLBusStopArrivalsViewModel,rhs :TFLBusStopArrivalsViewModel) -> (Bool) {
        return lhs.identifier == rhs.identifier
    }
    public var debugDescription: String {
        return "\n\(stationName) [\(identifier)] towards \(stationDetails)"
    }
    public var hashValue: Int {
        return self.identifier.hashValue
    }
    let identifier : String
    let stationName : String
    let stopLetter : String
    let stationDetails : String
    let distance : String
    let arrivalTimes : [LinePredictionViewModel]
    fileprivate static let distanceFormatter : LengthFormatter = {
        let formatter = LengthFormatter()
        formatter.unitStyle = .short
        formatter.numberFormatter.roundingMode = .halfUp
        formatter.numberFormatter.maximumFractionDigits = 0
        return formatter
    }()
    
    init(with arrivalInfo: TFLBusStopArrivalsInfo,using referenceDate : Date? = nil) {
        let towards = arrivalInfo.busStop.towards
        self.stationDetails = towards.isEmpty ? "" : NSLocalizedString("TFLBusStopArrivalsViewModel.towards", comment: "") + towards
        self.stopLetter = arrivalInfo.busStop.stopLetter
        self.stationName = arrivalInfo.busStop.name
        self.identifier = arrivalInfo.busStop.identifier
        self.distance = TFLBusStopArrivalsViewModel.distanceFormatter.string(fromValue: arrivalInfo.busStopDistance, unit: .meter)
        let referenceTime = referenceDate?.timeIntervalSinceReferenceDate ?? Date.timeIntervalSinceReferenceDate
        let filteredPredictions = arrivalInfo.arrivals.filter { $0.ttlSinceReferenceDate > referenceTime }
        self.arrivalTimes = filteredPredictions.flatMap { LinePredictionViewModel(with: $0,using: referenceTime) }
    }

    
}

