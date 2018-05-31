import UIKit

class TFLStationDetailTableViewCell: UITableViewCell {
    @IBOutlet weak var stationName : UILabel! = nil {
        didSet {
            self.stationName.font = UIFont.tflStationDetailTitle()
            self.stationName.textColor = UIColor.black
        }
    }
    @IBOutlet weak var upperStationPath : UIView!
    @IBOutlet weak var lowerStationPath : UIView!
    @IBOutlet weak var middleStationPath : UIView! = nil {
        didSet {
            self.middleStationPath.layer.cornerRadius = middleStationPath.frame.size.height/2
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.middleStationPath.isHidden = false
        prepareForReuse()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.stationName.text = nil
        self.upperStationPath.isHidden = true
        self.lowerStationPath.isHidden = true
    }
    
    func configure(with model: TFLStationDetailTableViewModel) {
//        self.stationName.text = model.stationName
//        
//        switch model.routePosition {
//        case .top:
//            self.lowerStationPath.isHidden = false
//        case .bottom:
//            self.upperStationPath.isHidden = false
//        case .middle:
//            self.lowerStationPath.isHidden = false
//            self.upperStationPath.isHidden = false
//        }
    }
}
