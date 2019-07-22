import UIKit

class TFLButton: UIButton {

    override func awakeFromNib() {
        super.awakeFromNib()
        self.layer.borderColor = UIColor.white.cgColor
        self.layer.borderWidth = 1.0
        self.layer.cornerRadius = 5
        self.setTitleColor(.white, for: .normal)
        updateColors()

    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle else {
            return
        }
        updateColors()
    }
}

fileprivate extension TFLButton {
    func updateColors() {
        self.backgroundColor = UIColor(named:"tflButtonColor")
    }
}
