import UIKit

class TFLLoadNearbyStationsView : UIView {
    override func awakeFromNib() {
        super.awakeFromNib()
        self.isAccessibilityElement = true
        self.accessibilityLabel = NSLocalizedString("TFLLoadNearbyStationsView.accessibilityTitle",comment:"")
        self.accessibilityTraits = .staticText
    }
    
    @IBOutlet weak var infoLabel : UILabel! = nil {
        didSet {
            self.infoLabel.font = UIFont.tflFont(size: 17)
            self.infoLabel.textColor = .black
            self.infoLabel.text = NSLocalizedString("TFLLoadNearbyStationsView.title", comment: "")
            self.infoLabel.isAccessibilityElement = false
        }
    }
}
