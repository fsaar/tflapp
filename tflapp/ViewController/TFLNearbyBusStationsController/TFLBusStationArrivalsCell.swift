import UIKit
import MapKit

class TFLBusStationArrivalsCell: UITableViewCell {
    @IBOutlet weak var stationName : UILabel!
    @IBOutlet weak var stationDetails : UILabel!
    @IBOutlet weak var distanceLabel : UILabel!
    @IBOutlet weak var predictionView : TFLBusPredictionView!
    @IBOutlet weak var noDataErrorLabel : UILabel!
    @IBOutlet weak var busStopLabel : UILabel!

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
        
        self.busStopLabel.font = UIFont.tflFont(size: 12)
        self.busStopLabel.textColor = UIColor.white
        self.busStopLabel.backgroundColor = UIColor.red
        self.busStopLabel.clipsToBounds = true
        self.busStopLabel.layer.cornerRadius = 5
        prepareForReuse()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.stationName.text = nil
        self.stationDetails.text = nil
        self.distanceLabel.text = nil
        self.noDataErrorLabel.isHidden = true
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
