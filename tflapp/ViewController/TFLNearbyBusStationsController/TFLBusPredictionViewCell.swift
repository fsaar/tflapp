import UIKit

class TFLBusPredictionViewCell: UICollectionViewCell {
    fileprivate var longTapClosure : (() -> Void)?
    fileprivate(set) var identifier : String?
    @IBOutlet var notificationBadgeBackground : UIView!
    @IBOutlet var notificationBadge : UIImageView! {
        didSet {
            self.notificationBadge.layer.borderWidth = 1
            self.notificationBadge.layer.cornerRadius = 7
            self.notificationBadge.clipsToBounds = true
        }
    }
    @IBOutlet weak var line : UILabel! = nil {
        didSet {
            self.line.font = UIFont.tflFontBusLineIdentifier()
            self.line.textColor = .white
            self.line.textAlignment = .center
            self.line.isOpaque = true
            self.line.backgroundColor = UIColor.red
            self.line.isAccessibilityElement = false
        }
    }
    @IBOutlet weak var arrivalTime : TFLAnimatedLabel! = nil {
        didSet {
            self.arrivalTime.font = UIFont.tflFontBusArrivalTime()
            self.arrivalTime.textColor = .black
            self.arrivalTime.isOpaque = true
            self.arrivalTime.backgroundColor = bgColor
            self.arrivalTime.textAlignment = .center
            self.arrivalTime.isAccessibilityElement = false
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.contentsGravity = .resizeAspectFill
        self.contentView.isOpaque = true
        self.selectedBackgroundView = nil
        self.isAccessibilityElement = true
        self.accessibilityTraits = [.staticText,.button]
   
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longTapHandler(_:)))
        self.contentView.addGestureRecognizer(gestureRecognizer)
        updateColors()
        prepareForReuse()
    }
    
    
    private let bgColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
    static var busPredictionViewBackgroundImage = defaultBackgroundImage()
       

    override func prepareForReuse() {
        super.prepareForReuse()
        self.line.text = nil
        self.arrivalTime.setText("-",animated: false)
        self.accessibilityLabel = nil
        self.notificationBadge.isHidden = true
        notificationBadgeBackground.isHidden  = true
        longTapClosure = nil
        self.identifier = nil
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        TFLBusPredictionViewCell.busPredictionViewBackgroundImage = TFLBusPredictionViewCell.defaultBackgroundImage()
        guard traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle else {
            return
        }
        updateColors()
    }

    func configure(with predictionViewModel: TFLBusStopArrivalsViewModel.LinePredictionViewModel,as update : Bool = false,using longTapClosure :@escaping () -> Void) {
        self.longTapClosure = longTapClosure
        self.identifier = predictionViewModel.identifier
        self.line.text = predictionViewModel.line
        let arrivalTime = self.arrivalTime.text ?? ""
        if !update || arrivalTime != predictionViewModel.eta {
            self.arrivalTime.setText(predictionViewModel.eta, animated: update)
        }
        self.accessibilityLabel = "\(predictionViewModel.line) - \(predictionViewModel.accessibilityTimeToStation)"
        updateBadgeIfNeedBe()
    }
    
    func updateBadgeIfNeedBe(_ animated : Bool = false) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.getPendingNotificationRequests { [weak self] requests in
            let identifier = self?.identifier ?? ""
            guard let request = requests.first(where:{ ($0.content.userInfo[TFLBusArrivalReminder.NotificationUserInfoKey.predictionIdentifier.rawValue] as? String) == identifier }),let userInfo = request.content.userInfo as? [String:Any], let minutes = userInfo[TFLBusArrivalReminder.NotificationUserInfoKey.minutesBeforeArrival.rawValue] as? Int  else {
                OperationQueue.main.addOperation{
                    self?.notificationBadge.isHidden = true
                    self?.notificationBadgeBackground.isHidden  = true
                }
                return
            }
            let image = UIImage(systemName: "\(minutes).circle.fill")
            OperationQueue.main.addOperation{
                self?.notificationBadgeBackground.isHidden  = false
                self?.notificationBadge.isHidden = false
                self?.notificationBadge.image = image
            }
        }
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        return layoutAttributes
    }
    
    func updateColors() {
        self.backgroundColor = UIColor(named: "tflBackgroundColor")
        self.contentView.backgroundColor = UIColor(named: "tflBackgroundColor")
        self.line.textColor = UIColor(named: "tflSecondaryTextColor")
        self.line.backgroundColor = UIColor(named: "tflLineBackgroundColor")
        self.notificationBadge.tintColor = UIColor(named: "tflLineBackgroundColor")
        self.notificationBadge.layer.borderColor = UIColor(named: "tflNotificationBadgeBorderColor")?.cgColor

        self.arrivalTime.backgroundColor = UIColor(named: "tflBusInfoBackgroundColor")
        self.arrivalTime.textColor = UIColor(named: "tflPrimaryTextColor") ?? UIColor.purple
        TFLBusPredictionViewCell.busPredictionViewBackgroundImage = TFLBusPredictionViewCell.defaultBackgroundImage()
        self.contentView.layer.contents = TFLBusPredictionViewCell.busPredictionViewBackgroundImage.cgImage
    }
    
    class func defaultBackgroundImage() -> UIImage {
            let bounds = CGRect(origin:.zero, size: CGSize(width: 54, height: 46))
            let busNumberRect = CGRect(x: 5, y: 4, width: 44, height: 20)
            let format = UIGraphicsImageRendererFormat()
            format.opaque = true
            let renderer = UIGraphicsImageRenderer(bounds: bounds,format: format)
            return renderer.image { context in
                UIColor(named: "tflBackgroundColor")?.setFill()
                context.fill(bounds)

                let path = UIBezierPath(roundedRect: bounds, cornerRadius: 5)
                let bgColor = UIColor(named: "tflBusInfoBackgroundColor")
                bgColor?.setFill()
                path.fill()

                let busNumberRectPath = UIBezierPath(roundedRect: busNumberRect , cornerRadius: busNumberRect.size.height/2)
                UIColor(named: "tflLineBackgroundColor")?.setFill()
                UIColor(named: "tflLineBackgroundBorderColor")?.setStroke()
                busNumberRectPath.fill()
                busNumberRectPath.stroke()
            }
    }
}

fileprivate extension TFLBusPredictionViewCell {
    @objc
    func longTapHandler(_ recognizer : UILongPressGestureRecognizer) {
        guard recognizer.state == .began else {
            return
        }
        longTapClosure?()
    }
}
