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
            self.nearbyContainer.backgroundColor = UIColor(red: 0, green: 0, blue: 0.6, alpha: 1)
        }
    }
    @IBOutlet weak var nearbyIndicator : UILabel! = nil {
        didSet {
            self.nearbyIndicator.backgroundColor = UIColor(red: 0, green: 0, blue: 0.6, alpha: 1)
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
    @IBOutlet weak var upperContainerHeight : NSLayoutConstraint!
    @IBOutlet weak var lowerContainerHeight : NSLayoutConstraint!
    
    @IBOutlet weak var upperContainer : UIView!
    @IBOutlet weak var lowerContainer : UIView!
    @IBOutlet weak var middleContainer : UIView!
    @IBOutlet weak var lowerStationPath : UIView!
    @IBOutlet weak var upperStationPath : UIView!
    @IBOutlet weak var middleStationPath : UIView! {
        didSet {
            self.middleStationPath.layer.cornerRadius = middleStationPath.frame.size.height/2
        }
    }
    lazy var arrivalInfoView : TFLArrivalInfoView = {
       let infoView = TFLArrivalInfoView()
        return infoView
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.middleContainer.insertSubview(self.animationContainer, belowSubview: self.middleStationPath)
        self.contentView.sendSubviewToBack(self.lowerContainer)
        self.upperContainer.addSubview(self.arrivalInfoView)

        NSLayoutConstraint.activate([
            self.middleStationPath.centerXAnchor.constraint(equalTo: self.animationContainer.centerXAnchor),
            self.middleStationPath.centerYAnchor.constraint(equalTo: self.animationContainer.centerYAnchor),
            self.upperStationPath.centerXAnchor.constraint(equalTo: arrivalInfoView.centerXAnchor),
            self.upperStationPath.centerYAnchor.constraint(equalTo: arrivalInfoView.centerYAnchor)
        ])
        prepareForReuse()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
       
        self.stationName.text = nil
        self.upperContainer.isHidden = false
        self.lowerContainer.isHidden = false
        self.nearbyContainer.isHidden = true
        self.upperStationPath.isHidden = true
        self.lowerStationPath.isHidden = true
        self.arrivalInfoView.isHidden = true
        self.animationContainer.stopAnimation()
    }

    func configure(with model: TFLStationDetailTableViewModel,and arrivalInfo : TFLVehicleArrivalInfo?, at index: Int) {
        let tuple = model.stations[index]
        self.stationName.text = tuple.name
        self.stopCodeLabel.text = tuple.stopCode
        
        let position = Position(index: index, max: max(model.stations.count-1,0))
        let showAnimation = model.showAnimation(for: index)
        let hasArrivalInfo = arrivalInfo != nil
        showPathComponents(for: position)
        setComponentHeight(for: position,hasAnimation: showAnimation,hasArrivalInfo: hasArrivalInfo)
        
        if showAnimation {
            self.nearbyContainer.isHidden = false
            self.animationContainer.startAnimation()
        }
        
        if let arrivalInfo = arrivalInfo {
            let animated = arrivalInfoView.isHidden ? false : true
            arrivalInfoView.isHidden = false
            arrivalInfoView.configure(with:  arrivalInfo.vehicleId, and: arrivalInfo.timeToStation,animated: animated)
        }
    }
}

fileprivate extension TFLStationDetailTableViewCell {
    func setComponentHeight(for position : Position, hasAnimation : Bool, hasArrivalInfo : Bool) {
        switch position {
        case .top:
            self.upperContainerHeight.constant = hasAnimation ? 14 : 0
            if hasArrivalInfo {
                self.upperContainerHeight.constant = hasAnimation ? 69 : 60
            }
            self.lowerContainerHeight.constant = hasAnimation ? 20 : 8
        case .bottom:
            self.upperContainerHeight.constant = hasAnimation ? 14 : 8
            if hasArrivalInfo {
                self.upperContainerHeight.constant = hasAnimation ? 69 : 60
            }
            self.lowerContainerHeight.constant = hasAnimation ? 20 : 0
        case .middle:
            self.upperContainerHeight.constant = hasAnimation ? 14 : 8
            if hasArrivalInfo {
                self.upperContainerHeight.constant = hasAnimation ? 69 : 60
            }
            self.lowerContainerHeight.constant = hasAnimation ? 20 : 8
        }
    }
    
    
    func showPathComponents(for position : Position) {
        switch position {
        case .top:
            self.lowerStationPath.isHidden = false
        case .bottom:
            self.upperStationPath.isHidden = false
        case .middle:
            self.upperStationPath.isHidden = false
            self.lowerStationPath.isHidden = false
        }
    }
}
