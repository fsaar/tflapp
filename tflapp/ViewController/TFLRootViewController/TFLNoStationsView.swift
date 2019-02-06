import UIKit

protocol TFLNoStationsViewDelegate : class {
    func didTap(noStationsButton: UIButton,in view : TFLNoStationsView)
}


class TFLNoStationsView : UIView {
    @IBOutlet weak var infoLabel : UILabel! = nil {
        didSet {
            self.infoLabel.font = UIFont.tflFont(size: 18)
            self.infoLabel.textColor = .white
            self.infoLabel.text = NSLocalizedString("TFLNoStationsView.title", comment: "")
        }
    }
    @IBOutlet weak var retryButton : TFLButton! = nil {
        didSet {
            self.retryButton.setTitle(NSLocalizedString("TFLNoStationsView.retryButtonTitle", comment: ""), for: UIControl.State.normal)
            self.retryButton.titleLabel?.font = UIFont.tflFont(size: 17)
        }
    }
    weak var delegate : TFLNoStationsViewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderColor = UIColor.red.cgColor
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 0.5
        self.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
    }

    @IBAction func buttonHandler(button : UIButton) {
        self.delegate?.didTap(noStationsButton: button, in: self)
    }

}
