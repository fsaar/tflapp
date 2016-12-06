import Foundation
import MapKit

public struct TFLBusStopArrivalsViewModel :CustomDebugStringConvertible,Hashable {
    public struct LinePredictionViewModel :CustomDebugStringConvertible,Hashable {
        let line : String
        let eta : String
        let identifier : String
        let timeToStation : Int

        init?(with busPrediction: TFLBusPrediction) {
            
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
            guard let timeToStation = busPrediction.timeToStation else {
                return nil
            }
            
            var timeOffset = Int(0)
            if let timeStampDate = ISO8601DateFormatter().date(from: busPrediction.timeStamp) {
               timeOffset = Int(Date().timeIntervalSince(timeStampDate))
            }
            self.identifier = busPrediction.identifier
            self.line = busPrediction.lineName
            self.timeToStation = Int(timeToStation)
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
    init(with arrivalInfo: TFLBusStopArrivalsInfo, distanceFormatter: LengthFormatter, and timeFormatter: DateFormatter) {
        let towards = arrivalInfo.busStop.towards
        self.stationDetails = towards.isEmpty ? "" : NSLocalizedString("TFLBusStopArrivalsViewModel.towards", comment: "") + towards
        self.stopLetter = arrivalInfo.busStop.stopLetter
        self.stationName = arrivalInfo.busStop.name
        self.identifier = arrivalInfo.busStop.identifier
        self.distance = distanceFormatter.string(fromValue: arrivalInfo.busStopDistance, unit: .meter)
        let now = Date()
        let filteredPredictions = arrivalInfo.arrivals.filter { busPrediction in
            guard let date = timeFormatter.date(from: busPrediction.ttl), let _ = busPrediction.timeToStation  else {
                return false
            }
            return date > now
        }
        self.arrivalTimes = filteredPredictions.flatMap { LinePredictionViewModel(with: $0) }.sorted (by:LinePredictionViewModel.compare)
    }

    
}

