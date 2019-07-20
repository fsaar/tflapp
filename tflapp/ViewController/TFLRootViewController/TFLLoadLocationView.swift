import UIKit

class TFLLoadLocationView : UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isAccessibilityElement = true
        self.accessibilityLabel = NSLocalizedString("TFLLoadLocationView.accessibilityTitle",comment:"")
    }
    
    @IBOutlet weak var infoLabel : UILabel! = nil {
        didSet {
            self.infoLabel.font = UIFont.tflFont(size: 17)
            self.infoLabel.textColor = .black
            self.infoLabel.text = NSLocalizedString("TFLLoadLocationView.title", comment: "")
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
