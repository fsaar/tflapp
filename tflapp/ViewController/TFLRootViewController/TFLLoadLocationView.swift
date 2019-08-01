import UIKit

class TFLLoadLocationView : UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isAccessibilityElement = true
        self.accessibilityLabel = NSLocalizedString("TFLLoadLocationView.accessibilityTitle",comment:"")
        self.accessibilityTraits = .staticText
        self.updateColors()
    }
    
    @IBOutlet weak var infoLabel : UILabel! = nil {
        didSet {
            self.infoLabel.font = UIFont.tflFont(size: 17)
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
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle else {
            return
        }
        updateColors()
    }
}


fileprivate extension TFLLoadLocationView {
    func updateColors() {
        self.backgroundColor = UIColor(named: "tflLoadLocationViewBackgroundColor")
        self.infoLabel.textColor = UIColor(named: "tflPrimaryTextColor")
        self.indicator.style = UIActivityIndicatorView.Style.medium
    }
}
