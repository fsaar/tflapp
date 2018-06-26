import UIKit

class TFLButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 5
        self.backgroundColor = .red
        self.setTitleColor(.white, for: .normal)

    }
}
