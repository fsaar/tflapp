import Foundation
import MapKit

public struct TFLBusStopArrivalsViewModel :Equatable,CustomDebugStringConvertible {
    struct LinePredictionViewModel :Equatable,CustomDebugStringConvertible {
        let line : String
        let eta : String
        let identifier : String
        init(with busPrediction: TFLBusPrediction) {
            
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
            var timeOffset = Int(0)
            if let timeStampDate = ISO8601DateFormatter().date(from: busPrediction.timeStamp) {
               timeOffset = Int(Date().timeIntervalSince(timeStampDate))
            }
            self.identifier = busPrediction.identifier
            self.line = busPrediction.lineName
            self.eta =  arrivalTime(in: max(Int((busPrediction.timeToStation ?? 0)) - timeOffset,0) )
        }
        public static func ==(lhs: LinePredictionViewModel,rhs :LinePredictionViewModel) -> (Bool) {
            return lhs.identifier == rhs.identifier
        }
        public var debugDescription: String {
            return "\n\(line) [\(identifier)]: \(eta)"
        }

        
    }
    public static func ==(lhs: TFLBusStopArrivalsViewModel,rhs :TFLBusStopArrivalsViewModel) -> (Bool) {
        return lhs.identifier == rhs.identifier
    }
    public var debugDescription: String {
        return "\n\(stationName) [\(identifier)] towards \(stationDetails)"
    }
    let identifier : String
    let stationName : String
    let stationDetails : String
    let distance : String
    let arrivalTimes : [LinePredictionViewModel]
    init(with arrivalInfo: TFLBusStopArrivalsInfo, distanceFormatter: LengthFormatter, and timeFormatter: DateFormatter) {
        let towards = arrivalInfo.busStop.towards
        self.stationDetails = towards.isEmpty ? "" : NSLocalizedString("TFLBusStopArrivalsViewModel.towards", comment: "") + towards
        self.stationName = arrivalInfo.busStop.name
        self.identifier = arrivalInfo.busStop.identifier
        self.distance = distanceFormatter.string(fromValue: arrivalInfo.busStopDistance, unit: .meter)
        
        let sortedPredictions =  arrivalInfo.arrivals.sorted { ($0.timeToStation ?? UInt.max) < ($1.timeToStation ?? UInt.max) }
        let now = Date()
        let filteredPredictions = sortedPredictions.filter { busPrediction in
            guard let date = timeFormatter.date(from: busPrediction.ttl) else {
                return false
            }
            return date > now
        }
        self.arrivalTimes = filteredPredictions.map { LinePredictionViewModel(with: $0) }
    }
    
}

