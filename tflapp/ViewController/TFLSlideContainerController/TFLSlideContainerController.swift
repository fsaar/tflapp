
import UIKit

class TFLSlideContainerController: UIViewController {
    var snapPositions: [CGFloat] = [0.04,0.4,0.70]
    fileprivate var snapHandler : TFLSnapHandler?
    var sliderViewUpdateBlock : ((_ slider : UIView,_ origin: CGPoint,_ final: Bool) -> ())? = nil {
        didSet {
            self.sliderViewUpdateBlock?(self.sliderContainerView, self.sliderContainerView.frame.origin,true)
        }
    }
    let maxVelocity : CGFloat = 100
    let defaultVelocity : CGFloat = 10
    let lightImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    @IBOutlet fileprivate weak var sliderHandleContainerView : UIView!
    @IBOutlet fileprivate weak var sliderHandleBackgroundView : UIView! = nil {
        didSet {
            self.sliderHandleBackgroundView.layer.cornerRadius = 10
            self.sliderHandleBackgroundView.layer.maskedCorners = [.layerMaxXMinYCorner , .layerMinXMinYCorner]
        }
    }
    @IBOutlet fileprivate weak var backgroundContainerView : UIView!
    @IBOutlet fileprivate var sliderContainerView : UIView! = nil
    @IBOutlet fileprivate var sliderContentContainerView : UIView!
    @IBOutlet fileprivate var sliderContainerViewTopConstraint : NSLayoutConstraint!
    @IBOutlet fileprivate var sliderHandleView : UIView! {
        didSet {
            self.sliderHandleView.layer.cornerRadius = self.sliderHandleView.frame.size.height/2
        }
    }
    @IBOutlet fileprivate var leftCustomViewContainer : UIView!
    @IBOutlet fileprivate var rightCustomViewContainer : UIView!
    var leftCustomView : UIView? {
        didSet {
            guard let leftCustomView = leftCustomView else {
                return
            }
            addCustomView(leftCustomView,to:leftCustomViewContainer)
        }
    }
    
    var rightCustomView : UIView? {
        didSet {
            guard let rightCustomView = rightCustomView else {
                return
            }
            addCustomView(rightCustomView,to:rightCustomViewContainer)
        }
    }

    
    func updateSliderContainerView(with position: CGPoint, animationTime : TimeInterval, velocity : CGFloat,final : Bool) {
        self.sliderContainerViewTopConstraint.constant = position.y
        let cappedVelocity = velocity > maxVelocity ? maxVelocity : velocity < -maxVelocity ? -maxVelocity : velocity
        UIView.animate(withDuration: animationTime, delay: 0,usingSpringWithDamping: 0.7, initialSpringVelocity : cappedVelocity, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
        self.sliderViewUpdateBlock?(view,position,final)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.snapHandler = TFLSnapHandler(with: self.sliderHandleContainerView,in: self.view, and: self.snapPositions) { [weak self] _,velocity,newOrigin,final in
            guard let self = self else {
                return
            }
            let currentY = self.view.convert(self.sliderHandleContainerView.frame.origin, from : self.sliderHandleContainerView.superview).y

            let nonzeroVelocity = velocity != 0 ? velocity : newOrigin.y < currentY ? -self.defaultVelocity : self.defaultVelocity
            let normalizedVelocity = final ? abs(newOrigin.y - currentY) / nonzeroVelocity : nonzeroVelocity
            let animationTime = final ? 0.5 : 0
            if final {
                self.lightImpactFeedbackGenerator.prepare()
                self.lightImpactFeedbackGenerator.impactOccurred()
            }
            self.updateSliderContainerView(with: newOrigin, animationTime: animationTime, velocity: normalizedVelocity,final: final)
        }
        let initPositionY = (self.snapPositions.first ?? 0) * self.view.frame.size.height
        self.updateSliderContainerView(with: CGPoint(x:self.sliderContainerView.frame.origin.x,y:initPositionY), animationTime: 0, velocity:0,final : true)
        updateColors()
    }

//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//        guard traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle else {
//            return
//        }
//        updateColors()
//    }

    func setContentControllers(with backgroundController : UIViewController,and sliderController : UIViewController) {
        add(backgroundController,to: backgroundContainerView )
        add(sliderController,to: sliderContentContainerView )
    }
}

fileprivate extension TFLSlideContainerController {
    func updateColors() {
        sliderHandleBackgroundView.backgroundColor = UIColor(named: "tflSlideBlackgroundViewColor")
        leftCustomViewContainer.backgroundColor = UIColor(named: "tflSlideBlackgroundViewColor")
        rightCustomViewContainer.backgroundColor = UIColor(named: "tflSlideBlackgroundViewColor")
    }
    
    func add(_ controller: UIViewController,to containerView: UIView) {
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        addChild(controller)
        containerView.addSubview(controller.view)
        controller.didMove(toParent: self)
        let dict : [String : Any] = ["contentView" : controller.view as Any] 
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[contentView]|", options: [], metrics: nil, views: dict)
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[contentView]|", options: [], metrics: nil, views: dict)
        containerView.addConstraints(hConstraints+vConstraints)
    }
    
     func addCustomView(_ view : UIView,to containerView : UIView) {
        containerView.addSubview(view)
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            view.topAnchor.constraint(equalTo: containerView.topAnchor)
            ])
    }
}
