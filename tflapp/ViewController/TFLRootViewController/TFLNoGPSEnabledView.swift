import UIKit

protocol TFLNoGPSEnabledViewDelegate : class {
    func didTap(noGPSEnabledButton: UIButton,in view : TFLNoGPSEnabledView)
}

class TFLNoGPSEnabledView : UIView {
    @IBOutlet weak var infoLabel : UILabel!
    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak  var settingsButton : TFLButton!
    weak var delegate : TFLNoGPSEnabledViewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderColor = UIColor.red.cgColor
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 0.5
        self.backgroundColor = UIColor(colorLiteralRed: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
        
        
        self.titleLabel.font = UIFont.tflBoldFont(size: 18)
        self.titleLabel.textColor = .white
        self.titleLabel.text = NSLocalizedString("TFLNoGPSEnabledView.headerTitle", comment: "")
        
        self.infoLabel.font = UIFont.tflFont(size: 15)
        self.infoLabel.textColor = .white
        self.infoLabel.text = NSLocalizedString("TFLNoGPSEnabledView.title", comment: "")
        self.settingsButton.setTitle(NSLocalizedString("TFLNoGPSEnabledView.settingsButtonTitle", comment: ""), for: UIControlState.normal)
        self.settingsButton.titleLabel?.font = UIFont.tflFont(size: 17)
    }
    
    @IBAction func buttonHandler(button : UIButton) {
        self.delegate?.didTap(noGPSEnabledButton: button, in: self)
    }
}
