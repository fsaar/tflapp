import UIKit

protocol TFLNoStationsViewDelegate : class {
    func didTap(noStationsButton: UIButton,in view : TFLNoStationsView)
}


class TFLNoStationsView : UIView {
    @IBOutlet weak var infoLabel : UILabel!
    @IBOutlet weak var retryButton : UIButton!
    weak var delegate : TFLNoStationsViewDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.infoLabel.font = UIFont.tflFont(size: 17)
        self.infoLabel.textColor = .black
        self.infoLabel.text = NSLocalizedString("TFLNoStationsView.title", comment: "")
        
        self.retryButton.setTitle(NSLocalizedString("TFLNoStationsView.retryButtonTitle", comment: ""), for: UIControlState.normal)
        self.retryButton.titleLabel?.font = UIFont.tflFont(size: 17)
        self.retryButton.setTitleColor(.black, for: .normal)

    }

    @IBAction func buttonHandler(button : UIButton) {
        self.delegate?.didTap(noStationsButton: button, in: self)
    }

}


