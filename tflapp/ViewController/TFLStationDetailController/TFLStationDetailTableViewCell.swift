import UIKit

class TFLStationDetailTableViewCell: UITableViewCell {
    enum Position {
        case top
        case middle
        case bottom
        init(index: Int,max : Int ) {
            let isFirst = index == 0
            let isLast = index == max
            if isFirst {
                self = .top
            }
            else if isLast {
                self = .bottom
            }
            else {
                self = .middle
            }

        }
    }
    @IBOutlet weak var stationName : UILabel! = nil {
        didSet {
            self.stationName.font = UIFont.tflStationDetailTitle()
            self.stationName.textColor = UIColor.black
        }
    }
    @IBOutlet weak var stopCodeLabel : UILabel! = nil {
        didSet {
            self.stopCodeLabel.font = UIFont.tflStationDetailStopCode()
            self.stopCodeLabel.textColor = UIColor.white
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

    func configure(with model: TFLStationDetailTableViewModel, at index: Int) {
        let tuple = model.stations[index]
        self.stationName.text = tuple.name
        self.stopCodeLabel.text = tuple.stopCode
        let position = Position(index: index, max: max(model.stations.count-1,0))
        switch position {
        case .top:
            self.lowerStationPath.isHidden = false
        case .bottom:
            self.upperStationPath.isHidden = false
        case .middle:
            self.lowerStationPath.isHidden = false
            self.upperStationPath.isHidden = false
        }
    }
}
