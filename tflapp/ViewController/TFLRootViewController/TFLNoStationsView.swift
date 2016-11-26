import UIKit

protocol TFLNoStationsViewDelegate : class {
    func didTap(noStationsButton: UIButton,in view : TFLNoStationsView)
}


class TFLNoStationsView : UIView {
    @IBOutlet weak var infoLabel : UILabel!
    @IBOutlet weak var retryButton : TFLButton!
    weak var delegate : TFLNoStationsViewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderColor = UIColor.red.cgColor
        self.layer.cornerRadius = 5
        self.layer.borderWidth = 0.5
        self.backgroundColor = UIColor(colorLiteralRed: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)

        
        self.infoLabel.font = UIFont.tflBoldFont(size: 18)
        self.infoLabel.textColor = .white
        self.infoLabel.text = NSLocalizedString("TFLNoStationsView.title", comment: "")
        
        self.retryButton.setTitle(NSLocalizedString("TFLNoStationsView.retryButtonTitle", comment: ""), for: UIControlState.normal)
        self.retryButton.titleLabel?.font = UIFont.tflFont(size: 17)

    }

    @IBAction func buttonHandler(button : UIButton) {
        self.delegate?.didTap(noStationsButton: button, in: self)
    }

}


