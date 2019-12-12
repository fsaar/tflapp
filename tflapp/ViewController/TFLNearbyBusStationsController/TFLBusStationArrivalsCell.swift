import UIKit
import MapKit

protocol TFLBusStationArrivalCellDelegate : AnyObject {
    func busStationArrivalCell(_ busStationArrivalCell: TFLBusStationArrivalsCell,didSelectLine line: String,with vehicleID: String,at station : String)
    func busStationArrivalCell(_ busStationArrivalCell: TFLBusStationArrivalsCell,showReminderForPrediction prediction: TFLBusStopArrivalsViewModel.LinePredictionViewModel,inArrivalViewModelWithIdentifier identifier : String?)

}

class TFLBusStationArrivalsCell: UITableViewCell {
    @IBOutlet weak var separator : UIView!
    @IBOutlet weak var stationName : UILabel! = nil {
        didSet {
            self.stationName.font = UIFont.tflFontStationHeader()
            self.stationName.textColor = UIColor.black
            self.stationName.isAccessibilityElement = false
        }
    }
    @IBOutlet weak var stationDetails : UILabel! = nil {
        didSet {
            self.stationDetails.font = UIFont.tflFontStationDetails()
            self.stationDetails.textColor = UIColor.darkGray
            self.stationDetails.isAccessibilityElement = false
        }
    }
    @IBOutlet weak var distanceLabel : UILabel! = nil {
        didSet {
            self.distanceLabel.font = UIFont.tflFontStationDistance()
            self.distanceLabel.textColor = UIColor.black
            self.distanceLabel.isAccessibilityElement = false
        }
    }
    @IBOutlet weak var predictionView : TFLBusPredictionView!

    @IBOutlet weak var busStopLabel : UILabel! = nil {
        didSet {
            self.busStopLabel.font = UIFont.tflFontStationIdentifier()
            self.busStopLabel.textColor = UIColor.white
            self.busStopLabel.backgroundColor = UIColor.red
            self.busStopLabel.clipsToBounds = true
            self.busStopLabel.layer.cornerRadius = 5
            self.busStopLabel.isAccessibilityElement = false
        }
    }
    weak var delegate : TFLBusStationArrivalCellDelegate?
    fileprivate var identifier : String?

    override func awakeFromNib() {
        super.awakeFromNib()
        isAccessibilityElement = false
        accessibilityTraits = [.staticText , .summaryElement]
        self.contentView.isAccessibilityElement = true
        self.contentView.accessibilityTraits = [.staticText,.summaryElement,.button]
        self.accessibilityElements = [self.contentView,predictionView].compactMap { $0 }
        predictionView.busPredictionViewDelegate = self
        updateColors()
        prepareForReuse()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.identifier = nil
        self.stationName.text = nil
        self.stationDetails.text = nil
        self.distanceLabel.text = nil
        self.predictionView.contentOffset = .zero
        self.predictionView.setPredictions(predictions: [],animated: false)
        self.accessibilityLabel = nil
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle else {
            return
        }
        updateColors()
    }

    func configure(with busStopArrivalViewModel: TFLBusStopArrivalsViewModel,animated: Bool = false) {
        self.identifier = busStopArrivalViewModel.identifier
        self.busStopLabel.text = busStopArrivalViewModel.stopLetter
        self.stationName.text = busStopArrivalViewModel.stationName
        self.stationDetails.text  = busStopArrivalViewModel.stationDetails
        self.distanceLabel.text = busStopArrivalViewModel.distance
        self.predictionView.setPredictions(predictions: busStopArrivalViewModel.arrivalTimes,animated: animated)
        self.contentView.accessibilityLabel = accessibilityLabel(with: busStopArrivalViewModel)
    }
}

// MARK: - Helper

fileprivate extension TFLBusStationArrivalsCell {
    func accessibilityLabel(with busStopArrivalViewModel: TFLBusStopArrivalsViewModel) -> String {
        let distance = Int(busStopArrivalViewModel.busStopDistance)
        let meterCopy = NSLocalizedString("Common.meter", comment: "")
        let metersCopy = NSLocalizedString("Common.meters", comment: "")
        let metersCopyToUse = distance == 1 ? meterCopy : metersCopy
        return "\(busStopArrivalViewModel.stationName) -- \(busStopArrivalViewModel.stationDetails) - \(distance) \(metersCopyToUse) away"
    }

    func updateColors() {
        self.contentView.backgroundColor = UIColor(named: "tflBackgroundColor")
        self.stationName.backgroundColor = UIColor(named: "tflBackgroundColor")
        self.stationDetails.backgroundColor = UIColor(named: "tflBackgroundColor")
        self.distanceLabel.backgroundColor = UIColor(named: "tflBackgroundColor")
        self.predictionView.backgroundColor = UIColor(named: "tflBackgroundColor")
        self.stationName.textColor = UIColor(named: "tflPrimaryTextColor")
        self.stationDetails.textColor = UIColor(named: "tflPrimaryTextColor")
        self.distanceLabel.textColor = UIColor(named: "tflPrimaryTextColor")
        self.busStopLabel.textColor =  UIColor(named: "tflStopCodeTextColor")
        self.busStopLabel.backgroundColor = UIColor(named: "tflStopCodeBackgroundColor")
        self.separator.backgroundColor = UIColor(named:"tflSeparatorColor")
    }
}

extension TFLBusStationArrivalsCell : TFLBusPredictionViewDelegate {
    func busPredictionView(_ busPredictionView: TFLBusPredictionView, showReminderForPrediction prediction: TFLBusStopArrivalsViewModel.LinePredictionViewModel) {
        self.delegate?.busStationArrivalCell(self, showReminderForPrediction: prediction, inArrivalViewModelWithIdentifier: identifier)
    }
    
    func busPredictionView(_ busPredictionView: TFLBusPredictionView, didSelectLine line: String,with vehicleID: String,at station : String) {
        self.delegate?.busStationArrivalCell(self, didSelectLine: line,with: vehicleID,at:station)
    }
}
