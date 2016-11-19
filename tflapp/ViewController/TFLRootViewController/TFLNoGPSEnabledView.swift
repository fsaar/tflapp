import UIKit

protocol TFLNoGPSEnabledViewDelegate : class {
    func didTap(noGPSEnabledButton: UIButton,in view : TFLNoGPSEnabledView)
}

class TFLNoGPSEnabledView : UIView {
    @IBOutlet weak var infoLabel : UILabel!
    @IBOutlet weak var titleLabel : UILabel!
    @IBOutlet weak  var settingsButton : UIButton!
    weak var delegate : TFLNoGPSEnabledViewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 0.5
        
        self.titleLabel.font = UIFont.tflBoldFont(size: 17)
        self.titleLabel.textColor = .black
        self.titleLabel.text = NSLocalizedString("TFLNoGPSEnabledView.headerTitle", comment: "")
        
        self.infoLabel.font = UIFont.tflFont(size: 15)
        self.infoLabel.textColor = .black
        self.infoLabel.text = NSLocalizedString("TFLNoGPSEnabledView.title", comment: "")
        self.settingsButton.setTitle(NSLocalizedString("TFLNoGPSEnabledView.settingsButtonTitle", comment: ""), for: UIControlState.normal)
        self.settingsButton.titleLabel?.font = UIFont.tflFont(size: 17)
        self.settingsButton.setTitleColor(.black, for: .normal)
    }
    
    @IBAction func buttonHandler(button : UIButton) {
        self.delegate?.didTap(noGPSEnabledButton: button, in: self)
    }
}
