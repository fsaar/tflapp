
import UIKit

class TFLAnimiatedLabel: UIView {

    fileprivate var label2TopConstraint : NSLayoutConstraint?
    var bgColor: UIColor? =  nil {
        didSet {
            self.labels.forEach { $0.backgroundColor = self.bgColor }
        }
    }
    
    var textAlignment : NSTextAlignment = .left {
        didSet {
            self.labels.forEach { $0.textAlignment = self.textAlignment }
        }
    }
    var textColor : UIColor = .black {
        didSet {
            self.labels.forEach { $0.textColor = self.textColor }
        }
    }
    var font : UIFont = .systemFont(ofSize: 10) {
        didSet {
            self.labels.forEach { $0.font = self.font}
        }
    }
    
    fileprivate(set) var text : String?
    
    fileprivate var labels : [UILabel] {
        return self.subviews.flatMap { $0 as? UILabel }
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setText(_ newText: String?, animated : Bool = false) {
        self.text = newText
        if (animated)
        {
            self.label2TopConstraint?.constant = self.frame.size.height
            self.labels.first?.text = newText
            UIView.animate(withDuration: 0.5, animations: {
                self.layoutIfNeeded()
            }) { _ in
                self.labels.last?.text = newText
                self.label2TopConstraint?.constant = 0
                self.layoutIfNeeded()
            }
        }
        else
        {
            self.labels.last?.text = newText
        }
    }
}

fileprivate extension TFLAnimiatedLabel {
    func animatedLabel() -> UILabel {
        let label = UILabel(frame: self.frame)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.textColor = self.textColor
        label.font = self.font
        label.textAlignment = self.textAlignment
        label.backgroundColor = self.bgColor
        label.isOpaque = true
        return label
    }
    
    func setup() {
        self.clipsToBounds = true
        let label1 = animatedLabel()
        let label2 = animatedLabel()
        self.addSubview(label1)
        self.addSubview(label2)
        
        let dict = ["label1" : label1,"label2" : label2]
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[label1]|", options: [], metrics: nil, views: dict)
        let hConstraints2 = NSLayoutConstraint.constraints(withVisualFormat: "H:|[label2]|", options: [], metrics: nil, views: dict)
        self.addConstraints(hConstraints+hConstraints2)
        let topConstraint = NSLayoutConstraint(item: label2, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0)
        self.label2TopConstraint = topConstraint
        let label1BottomConstraint = NSLayoutConstraint(item: label1, attribute: .bottom, relatedBy: .equal, toItem: label2, attribute: .top, multiplier: 1.0, constant: 0)
        let label1HeightConstraint = NSLayoutConstraint(item: label1, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1.0, constant: 0)
        let label2HeightConstraint = NSLayoutConstraint(item: label2, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1.0, constant: 0)
        self.addConstraints([label1BottomConstraint,label1HeightConstraint,label2HeightConstraint,topConstraint])
    }
}
