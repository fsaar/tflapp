import UIKit

class TFLLoadArrivalTimesView : UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isAccessibilityElement = true
        self.accessibilityLabel = NSLocalizedString("TFLLoadArrivalTimesView.accessiblityTitle",comment:"")
        self.accessibilityTraits = .staticText
    }
    
    @IBOutlet weak var infoLabel : UILabel! = nil {
        didSet {
            self.infoLabel.font = UIFont.tflFont(size: 17)
            self.infoLabel.textColor = .black
            self.infoLabel.text = NSLocalizedString("TFLLoadArrivalTimesView.title", comment: "")
            self.infoLabel.isAccessibilityElement = false
        }
    }
    @IBOutlet weak var indicator : UIActivityIndicatorView!

    override var isHidden: Bool  {
        didSet {
            if let indicator = self.indicator {
                if isHidden {
                    indicator.stopAnimating()
                }
                else
                {
                    indicator.startAnimating()
                }
            }
        }
    }
}
