import UIKit

class TFLLoadNearbyStationsView : UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isAccessibilityElement = true
        self.accessibilityLabel = NSLocalizedString("TFLLoadNearbyStationsView.accessibilityTitle",comment:"")
        self.accessibilityTraits = .staticText
        self.updateColors()
    }
    
    @IBOutlet weak var infoLabel : UILabel! = nil {
        didSet {
            self.infoLabel.font = UIFont.tflFont(size: 17)
            self.infoLabel.text = NSLocalizedString("TFLLoadNearbyStationsView.title", comment: "")
            self.infoLabel.isAccessibilityElement = false
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


fileprivate extension TFLLoadNearbyStationsView {
    func updateColors() {
        self.backgroundColor = UIColor(named: "tflLoadLocationViewBackgroundColor")
        self.infoLabel.textColor = UIColor(named: "tflPrimaryTextColor")
    }
}
