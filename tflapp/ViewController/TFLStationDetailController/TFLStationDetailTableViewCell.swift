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
    let animationContainer : TFLCircleAnimationView = {
        let view = TFLCircleAnimationView(frame:.zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 56).isActive = true
        view.heightAnchor.constraint(equalToConstant: 56).isActive = true
        return view
    }()
    @IBOutlet weak var nearbyContainer : UIView! = nil {
        didSet {
            self.nearbyContainer.clipsToBounds = true
            self.nearbyContainer.layer.cornerRadius = 8
            self.nearbyContainer.backgroundColor = UIColor.darkGray
        }
    }
    @IBOutlet weak var nearbyIndicator : UILabel! = nil {
        didSet {
            self.nearbyIndicator.backgroundColor = UIColor.darkGray
            self.nearbyIndicator.font = UIFont.tflStationDetailNearbyTitle()
            self.nearbyIndicator.textColor = .white
            self.nearbyIndicator.text = NSLocalizedString("TFLStationDetailNearby.title", comment: "")
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
        self.contentView.insertSubview(self.animationContainer, belowSubview: self.middleStationPath)
        NSLayoutConstraint.activate([
            self.middleStationPath.centerXAnchor.constraint(equalTo: self.animationContainer.centerXAnchor),
            self.middleStationPath.centerYAnchor.constraint(equalTo: self.animationContainer.centerYAnchor),
            ])
        prepareForReuse()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.stationName.text = nil
        self.upperStationPath.isHidden = true
        self.lowerStationPath.isHidden = true
        self.nearbyContainer.isHidden = true

        self.animationContainer.stopAnimation()
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
        
        let showAnimation = model.showAnimation(for: index)
        if showAnimation {
            self.nearbyContainer.isHidden = false
            self.animationContainer.startAnimation()
        }
    }
}
