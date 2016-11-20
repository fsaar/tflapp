import UIKit

class TFLBusPredictionViewCell: UICollectionViewCell {
    @IBOutlet weak var line : UILabel!
    @IBOutlet weak var arrivalTime : UILabel!
    @IBOutlet weak var lineBackground : UIView!
    private let bgColor = UIColor.init(colorLiteralRed: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
    override func awakeFromNib() {
        super.awakeFromNib()
        self.line.font = UIFont.tflFont(size: 12)
        self.line.textColor = .white
        self.line.isOpaque = true
        self.line.backgroundColor = UIColor.red
        self.lineBackground.clipsToBounds = true
        self.lineBackground.layer.cornerRadius = self.lineBackground.frame.size.height/2
        self.lineBackground.backgroundColor = UIColor.red
        self.lineBackground.layer.borderColor = UIColor.white.cgColor
        self.lineBackground.layer.borderWidth = 1
        self.lineBackground.isOpaque = true
        self.arrivalTime.font = UIFont.tflFont(size: 12)
        self.arrivalTime.textColor = .black
        self.arrivalTime.isOpaque = true
        self.arrivalTime.backgroundColor = bgColor
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.line.text = nil
        self.arrivalTime.text = "-"
    }
    
    func configure(with predictionViewModel: TFLBusStopArrivalsViewModel.LinePredictionViewModel) {
        self.line.text = predictionViewModel.line
        self.arrivalTime.text =  predictionViewModel.eta
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        if let context = context {
            let path = UIBezierPath(roundedRect:  self.bounds, cornerRadius: 5)
            context.setFillColor(bgColor.cgColor)
            path.fill()
        }
        
    }
}

