import UIKit
import MapKit

class TFLBusStationArrivalsCell: UITableViewCell {
    @IBOutlet weak var stationName : UILabel!
    @IBOutlet weak var stationDetails : UILabel!
    @IBOutlet weak var distanceLabel : UILabel!
    @IBOutlet weak var predictionView : TFLBusPredictionView!
    @IBOutlet weak var noDataErrorLabel : UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        self.stationName.font = UIFont.tflBoldFont(size: 17)
        self.stationName.textColor = UIColor.black
        self.stationDetails.font = UIFont.tflFont(size: 14)
        self.stationDetails.textColor = UIColor.darkGray
        self.distanceLabel.font = UIFont.tflFont(size: 14)
        self.distanceLabel.textColor = UIColor.black
        self.noDataErrorLabel.text = NSLocalizedString("TFLBusStationArrivalsCell.noDataError", comment: "")
        self.noDataErrorLabel.font = UIFont.tflFont(size: 14)
        self.noDataErrorLabel.textColor = UIColor.black
        prepareForReuse()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.stationName.text = nil
        self.stationDetails.text = nil
        self.distanceLabel.text = nil
        self.noDataErrorLabel.isHidden = true
    }
    
    func configure(with busStopArrivalViewModel: TFLBusStopArrivalsViewModel) {
        self.stationName.text = busStopArrivalViewModel.stationName
        self.stationDetails.text  = busStopArrivalViewModel.stationDetails
        self.distanceLabel.text = busStopArrivalViewModel.distance
        self.predictionView.predictions = busStopArrivalViewModel.arrivalTimes
        self.noDataErrorLabel.isHidden = !busStopArrivalViewModel.arrivalTimes.isEmpty
    }
    

}
