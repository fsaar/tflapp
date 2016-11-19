import UIKit

class TFLLoadNearbyStationsView : UIView {
    @IBOutlet weak var infoLabel : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.infoLabel.font = UIFont.tflFont(size: 17)
        self.infoLabel.textColor = .black
        self.infoLabel.text = NSLocalizedString("TFLLoadNearbyStationsView.title", comment: "")
    }
}
