import Foundation
import MapKit

public struct TFLBusStopArrivalsViewModel :CustomDebugStringConvertible,Hashable {
    public struct LinePredictionViewModel :CustomDebugStringConvertible,Hashable {
        let line : String
        let eta : String
        let identifier : String
        let timeToStation : Int
        static let minTitle = "1 \(NSLocalizedString("TFLBusStopArrivalsViewModel.min", comment: ""))"
        static let minsTitle = NSLocalizedString("TFLBusStopArrivalsViewModel.mins", comment: "")

        init(with busPrediction: TFLBusPrediction,using referenceTime : TimeInterval) {
            func arrivalTime(in secs : Int) -> String {
                var timeString = ""

                switch secs {
                case ..<30:
                    timeString = NSLocalizedString("TFLBusStopArrivalsViewModel.due", comment: "")
                case 30..<60:
                    timeString = "1 " + NSLocalizedString("TFLBusStopArrivalsViewModel.min", comment: "")
                case 60..<(99*60):
                    let mins = secs/60
                    timeString = "\(mins) \(LinePredictionViewModel.minsTitle)"
                    if mins == 1 {
                        timeString = LinePredictionViewModel.minTitle
                    }
                default:
                    timeString = ""
                }
                return timeString
            }
            let timeStampSinceReferenceDate = busPrediction.timeStamp.timeIntervalSinceReferenceDate
            let timeOffset = Int(referenceTime - timeStampSinceReferenceDate)
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
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(self.identifier)
        }



    }
    public static func ==(lhs: TFLBusStopArrivalsViewModel,rhs :TFLBusStopArrivalsViewModel) -> (Bool) {
        return lhs.identifier == rhs.identifier
    }
    public var debugDescription: String {
        return "\n\(stationName) [\(identifier)] towards \(stationDetails)"
    }
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.identifier)
    }
    let identifier : String
    let stationName : String
    let stopLetter : String
    let stationDetails : String
    let busStopDistance : Double
    let distance : String
    let arrivalTimes : [LinePredictionViewModel]
    fileprivate static let distanceFormatter : LengthFormatter = {
        let formatter = LengthFormatter()
        formatter.unitStyle = .short
        formatter.numberFormatter.roundingMode = .halfUp
        formatter.numberFormatter.maximumFractionDigits = 0
        return formatter
    }()

    public static func compare(lhs: TFLBusStopArrivalsViewModel, rhs: TFLBusStopArrivalsViewModel) -> Bool  {
        return lhs.busStopDistance <= rhs.busStopDistance
    }


    init(with arrivalInfo: TFLBusStopArrivalsInfo,using referenceDate : Date? = nil) {
        let towards = arrivalInfo.busStop.towards ?? ""
        self.stationDetails = towards.isEmpty ? "" : NSLocalizedString("TFLBusStopArrivalsViewModel.towards", comment: "") + towards
        self.busStopDistance = arrivalInfo.busStopDistance
        self.stopLetter = arrivalInfo.busStop.stopLetter ?? ""
        self.stationName = arrivalInfo.busStop.name
        self.identifier = arrivalInfo.busStop.identifier
        self.distance = TFLBusStopArrivalsViewModel.distanceFormatter.string(fromValue: arrivalInfo.busStopDistance, unit: .meter)
        let referenceTime = referenceDate?.timeIntervalSinceReferenceDate ?? Date.timeIntervalSinceReferenceDate
        let adjustedReferenceTime =  referenceTime - 30
        let filteredPredictions = arrivalInfo.arrivals.filter { $0.timeToLive.timeIntervalSinceReferenceDate > adjustedReferenceTime }
        self.arrivalTimes = filteredPredictions.map { LinePredictionViewModel(with: $0,using: referenceTime) }
    }


}
