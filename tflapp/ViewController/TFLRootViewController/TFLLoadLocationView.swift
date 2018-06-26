import UIKit

class TFLLoadLocationView : UIView {
    @IBOutlet weak var infoLabel : UILabel! = nil {
        didSet {
            self.infoLabel.font = UIFont.tflFont(size: 17)
            self.infoLabel.textColor = .black
            self.infoLabel.text = NSLocalizedString("TFLLoadLocationView.title", comment: "")
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
