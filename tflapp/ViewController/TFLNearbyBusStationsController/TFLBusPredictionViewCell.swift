import UIKit

class TFLBusPredictionViewCell: UICollectionViewCell {
    @IBOutlet weak var line : UILabel! = nil {
        didSet {
            self.line.font = UIFont.tflFontBusLineIdentifier()
            self.line.textColor = .white
            self.line.textAlignment = .center
            self.line.isOpaque = true
            self.line.backgroundColor = UIColor.red
        }
    }
    @IBOutlet weak var arrivalTime : TFLAnimiatedLabel! = nil {
        didSet {
            self.arrivalTime.font = UIFont.tflFontBusArrivalTime()
            self.arrivalTime.textColor = .black
            self.arrivalTime.isOpaque = true
            self.arrivalTime.bgColor = bgColor
            self.arrivalTime.textAlignment = .center
        }
    }
    @IBOutlet weak var bgImage : UIImageView! = nil {
        didSet {
            self.bgImage.image = TFLBusPredictionViewCell.busPredictionViewBackgroundImage
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectedBackgroundView = nil
        prepareForReuse()

    }
    private let bgColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
    static var busPredictionViewBackgroundImage: UIImage = {
        let bounds = CGRect(origin:.zero, size: CGSize(width: 54, height: 46))
        let busNumberRect = CGRect(x: 5, y: 4, width: 44, height: 20)
        let format = UIGraphicsImageRendererFormat()
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(bounds: bounds,format: format)
        return renderer.image { context in
            UIColor.white.setFill()
            context.fill(bounds)

            let path = UIBezierPath(roundedRect: bounds, cornerRadius: 5)
            let bgColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
            bgColor.setFill()
            path.fill()

            let busNumberRectPath = UIBezierPath(roundedRect: busNumberRect , cornerRadius: busNumberRect.size.height/2)
            UIColor.red.setFill()
            UIColor.white.setStroke()
            busNumberRectPath.fill()
            busNumberRectPath.stroke()
        }
    }()

    override func prepareForReuse() {
        super.prepareForReuse()
        self.line.text = nil
        self.arrivalTime.setText("-")
    }

    func configure(with predictionViewModel: TFLBusStopArrivalsViewModel.LinePredictionViewModel,as update : Bool = false) {
        self.line.text = predictionViewModel.line
        let arrivalTime = self.arrivalTime.text ?? ""
        if !update || arrivalTime != predictionViewModel.eta {
            self.arrivalTime.setText(predictionViewModel.eta, animated: update)
        }
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        return layoutAttributes
    }

}

