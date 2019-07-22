import UIKit

protocol TFLNoGPSEnabledViewDelegate : AnyObject {
    func didTap(noGPSEnabledButton: UIButton,in view : TFLNoGPSEnabledView)
}

class TFLNoGPSEnabledView : UIView {
    @IBOutlet weak var infoLabel : UILabel! = nil {
        didSet {
            self.infoLabel.font = UIFont.tflFont(size: 16)
            self.infoLabel.text = NSLocalizedString("TFLNoGPSEnabledView.title", comment: "")
        }
    }
    @IBOutlet weak var titleLabel : UILabel! = nil {
        didSet {
            self.titleLabel.font = UIFont.tflFont(size: 18)
            self.titleLabel.text = NSLocalizedString("TFLNoGPSEnabledView.headerTitle", comment: "")
        }
    }
    @IBOutlet weak  var settingsButton : TFLButton! = nil {
        didSet {
            self.settingsButton.setTitle(NSLocalizedString("TFLNoGPSEnabledView.settingsButtonTitle", comment: ""), for: UIControl.State.normal)
            self.settingsButton.titleLabel?.font = UIFont.tflFont(size: 17)
        }
    }
    weak var delegate : TFLNoGPSEnabledViewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderColor = UIColor.red.cgColor
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 0.5
        updateColors()
    }

    @IBAction func buttonHandler(button : UIButton) {
        self.delegate?.didTap(noGPSEnabledButton: button, in: self)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle else {
            return
        }
        updateColors()
    }
}


fileprivate extension TFLNoGPSEnabledView {
    func updateColors() {
        self.backgroundColor = UIColor(named: "tflErrorViewBackgroundColor")
        self.titleLabel.textColor = UIColor(named: "tflSecondaryTextColor")
        self.infoLabel.textColor = UIColor(named: "tflSecondaryTextColor")
    }
}
