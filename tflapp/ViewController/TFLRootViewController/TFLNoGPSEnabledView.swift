import UIKit

class TFLErrorView : UIView {
    typealias ButtonHandler = (_ button : UIButton) -> Void
    fileprivate var buttonHandler : ButtonHandler?
    @IBOutlet weak var infoLabel : UILabel! = nil {
        didSet {
            self.infoLabel.font = UIFont.tflFont(size: 16)
            self.infoLabel.text = nil
        }
    }
    @IBOutlet weak var titleLabel : UILabel! = nil {
        didSet {
            self.titleLabel.font = UIFont.tflFont(size: 18)
            self.titleLabel.text = nil
        }
    }
    @IBOutlet weak  var settingsButton : TFLButton! = nil {
        didSet {
            self.settingsButton.titleLabel?.font = UIFont.tflFont(size: 17)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderColor = UIColor.red.cgColor
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 0.5
        updateColors()
    }

    func setTitle(_ title : String,description : String?,buttonCaption : String?,accessibilityLabel: String, using buttonHandler:@escaping  ButtonHandler) {
        self.accessibilityLabel = accessibilityLabel
        self.titleLabel.text =  title
        self.settingsButton.setTitle(buttonCaption,for: .normal)
        self.infoLabel.text = description
        self.buttonHandler = buttonHandler
    }
    
    @IBAction func buttonHandler(button : UIButton) {
        buttonHandler?(button)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle else {
            return
        }
        updateColors()
    }
}


fileprivate extension TFLErrorView {
    func updateColors() {
        self.backgroundColor = UIColor(named: "tflErrorViewBackgroundColor")
        self.titleLabel.textColor = UIColor(named: "tflSecondaryTextColor")
        self.infoLabel.textColor = UIColor(named: "tflSecondaryTextColor")
    }
}
