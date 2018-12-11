import UIKit
import MapKit

protocol TFLBusStationArrivalCellDelegate : class {
    func busStationArrivalCell(_ busStationArrivalCell: TFLBusStationArrivalsCell,didSelectLine line: String, towards direction : String)
}

class TFLBusStationArrivalsCell: UITableViewCell {
    @IBOutlet weak var stationName : UILabel! = nil {
        didSet {
            self.stationName.font = UIFont.tflFontStationHeader()
            self.stationName.textColor = UIColor.black
        }
    }
    @IBOutlet weak var stationDetails : UILabel! = nil {
        didSet {
            self.stationDetails.font = UIFont.tflFontStationDetails()
            self.stationDetails.textColor = UIColor.darkGray
        }
    }
    @IBOutlet weak var distanceLabel : UILabel! = nil {
        didSet {
            self.distanceLabel.font = UIFont.tflFontStationDistance()
            self.distanceLabel.textColor = UIColor.black
        }
    }
    @IBOutlet weak var predictionView : TFLBusPredictionView!

    @IBOutlet weak var noDataErrorLabel : UILabel! = nil {
        didSet {
            self.noDataErrorLabel.text = NSLocalizedString("TFLBusStationArrivalsCell.noDataError", comment: "")
            self.noDataErrorLabel.font = UIFont.tflFont(size: 14)
            self.noDataErrorLabel.textColor = UIColor.black
        }
    }
    @IBOutlet weak var busStopLabel : UILabel! = nil {
        didSet {
            self.busStopLabel.font = UIFont.tflFontStationIdentifier()
            self.busStopLabel.textColor = UIColor.white
            self.busStopLabel.backgroundColor = UIColor.red
            self.busStopLabel.clipsToBounds = true
            self.busStopLabel.layer.cornerRadius = 5
        }
    }
    weak var delegate : TFLBusStationArrivalCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        predictionView.busPredictionViewDelegate = self
        prepareForReuse()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.stationName.text = nil
        self.stationDetails.text = nil
        self.distanceLabel.text = nil
        self.noDataErrorLabel.isHidden = true
        self.predictionView.contentOffset = .zero
        self.predictionView.setPredictions(predictions: [],animated: false)
    }

    func configure(with busStopArrivalViewModel: TFLBusStopArrivalsViewModel) {
        self.busStopLabel.text = busStopArrivalViewModel.stopLetter
        self.stationName.text = busStopArrivalViewModel.stationName
        self.stationDetails.text  = busStopArrivalViewModel.stationDetails
        self.distanceLabel.text = busStopArrivalViewModel.distance
        self.predictionView.setPredictions(predictions: busStopArrivalViewModel.arrivalTimes,animated: true)
        self.noDataErrorLabel.isHidden = !busStopArrivalViewModel.arrivalTimes.isEmpty
    }


}

extension TFLBusStationArrivalsCell : TFLBusPredictionViewDelegate {
    func busPredictionView(_ busPredictionView: TFLBusPredictionView, didSelectLine line: String,towards direction: String) {
        self.delegate?.busStationArrivalCell(self, didSelectLine: line,towards: direction)
    }
}
