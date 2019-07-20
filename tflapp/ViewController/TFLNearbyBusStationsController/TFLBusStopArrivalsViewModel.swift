import Foundation
import MapKit

public struct TFLBusStopArrivalsViewModel :CustomDebugStringConvertible,Hashable {
    public struct LinePredictionViewModel :CustomDebugStringConvertible,Hashable {
        let line : String
        let eta : String
        let accessibilityTimeToStation : String
        let identifier : String
        let busStopIdentifier : String
        let vehicleID : String
        let timeToStation : Int
        let towards : String
        static let minTitle = "1 \(NSLocalizedString("Common.min", comment: ""))"
        static let minsTitle = NSLocalizedString("Common.mins", comment: "")
        static let minuteTitle = "1 \(NSLocalizedString("Common.minute", comment: ""))"
        static let minutesTitle = NSLocalizedString("Common.minutes", comment: "")

        init(with busPrediction: TFLBusPrediction,using referenceTime : TimeInterval) {
            func arrivalTime(in secs : Int) -> (displayTime:String,accessibilityTime : String) {
                var timeString = ""
                var accessibilityTimeString = ""
                switch secs {
                case ..<30:
                    timeString = NSLocalizedString("Common.due", comment: "")
                    accessibilityTimeString = NSLocalizedString("Common.due", comment: "")
                case 30..<60:
                    timeString = LinePredictionViewModel.minTitle
                    accessibilityTimeString = "in \(TFLBusStopArrivalsViewModel.LinePredictionViewModel.minuteTitle)"
                case 60..<(99*60):
                    let mins = secs/60
                    timeString = "\(mins) \(LinePredictionViewModel.minsTitle)"
                    accessibilityTimeString = "in \(mins) \(TFLBusStopArrivalsViewModel.LinePredictionViewModel.minutesTitle)"
                    if mins == 1 {
                        timeString = LinePredictionViewModel.minTitle
                        accessibilityTimeString = "in \(TFLBusStopArrivalsViewModel.LinePredictionViewModel.minuteTitle)"
                    }
                default:
                    break
                }
                return (timeString,accessibilityTimeString)
            }
            let timeStampSinceReferenceDate = busPrediction.timeStamp.timeIntervalSinceReferenceDate
            let timeOffset = Int(referenceTime - timeStampSinceReferenceDate)
            self.identifier = busPrediction.identifier
            self.busStopIdentifier = busPrediction.busStopIdentifier
            self.vehicleID = busPrediction.vehicleId
            self.line = busPrediction.lineName
            self.timeToStation = Int(busPrediction.timeToStation)
            (self.eta,self.accessibilityTimeToStation) =  arrivalTime(in: Int(timeToStation) - timeOffset )
            self.towards = busPrediction.towards
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
        self.stationDetails = towards.isEmpty ? "" : "\(NSLocalizedString("Common.towards", comment: "")) \(towards)"
        self.busStopDistance = arrivalInfo.busStopDistance
        self.stopLetter = arrivalInfo.busStop.stopLetter ?? ""
        self.stationName = arrivalInfo.busStop.name
        self.identifier = arrivalInfo.busStop.identifier
        self.distance = TFLBusStopArrivalsViewModel.distanceFormatter.string(fromValue: arrivalInfo.busStopDistance, unit: .meter)
        let referenceTime = referenceDate ?? Date()
        let filteredPredictions = arrivalInfo.liveArrivals(with: referenceTime)
        self.arrivalTimes = filteredPredictions.map { LinePredictionViewModel(with: $0,using: referenceTime.timeIntervalSinceReferenceDate) }
    }


}
