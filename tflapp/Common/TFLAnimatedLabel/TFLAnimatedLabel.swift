
import UIKit

class TFLAnimatedLabel: UIView {
    
    fileprivate var label2TopConstraint : NSLayoutConstraint?
    override var backgroundColor: UIColor? {
        didSet {
            self.labels.forEach { $0.backgroundColor = self.backgroundColor }
        }
    }
    
    var minimumScaleFactor : CGFloat = 0.5 {
        didSet {
            self.labels.forEach { $0.minimumScaleFactor = self.minimumScaleFactor  }
        }
    }
    
    var textAlignment : NSTextAlignment = .left {
        didSet {
            self.labels.forEach { $0.textAlignment = self.textAlignment  }
        }
    }
    var textColor : UIColor = .black {
        didSet {
            self.labels.forEach { $0.textColor = self.textColor }
        }
    }
    var font : UIFont = .systemFont(ofSize: 10) {
        didSet {
            self.labels.forEach { $0.font = self.font }
        }
    }
    
    fileprivate(set) var text : String?
    
    fileprivate var labels : [UILabel] {
        return self.subviews.compactMap { $0 as? UILabel }
    }
    
    private lazy var animator : UIViewPropertyAnimator = {
        let springParameters = UISpringTimingParameters(dampingRatio: 0.3)
        let animator = UIViewPropertyAnimator(duration: 1, timingParameters: springParameters)
        
        return animator
    }()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    func setText(_ newText: String?, animated : Bool = false) {
        guard  newText != text else {
            return
        }
        self.text = newText
        self.labels.first?.text = newText
        guard animated else {
            self.label2TopConstraint?.constant = 0
            self.layoutIfNeeded()
            self.labels.last?.text = newText
            return
        }

        self.label2TopConstraint?.constant = self.frame.size.height
        startAnimation({ self.layoutIfNeeded() }) { [weak self] in
            self?.labels.last?.text = self?.text
            self?.label2TopConstraint?.constant = 0
            self?.layoutIfNeeded()
        }
    }
}

fileprivate extension TFLAnimatedLabel {
    func startAnimation(_ animation:@escaping () -> Void,using completionBlock: @escaping () -> Void) {
        animator.stopAnimation(true)
        animator.addAnimations {
            animation()
        }
        animator.addCompletion { _ in
            completionBlock()
        }
        animator.startAnimation()
    }
    
    
    func animatedLabel() -> UILabel {
        let label = UILabel(frame: self.frame)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.textColor = self.textColor
        label.font = self.font
        label.textAlignment = self.textAlignment
        label.backgroundColor = self.backgroundColor
        label.isOpaque = true
        label.minimumScaleFactor =  0.5
        return label
    }
    
    
    func addLabels() {
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
    
    func setup() {
        addLabels()
    }
}
