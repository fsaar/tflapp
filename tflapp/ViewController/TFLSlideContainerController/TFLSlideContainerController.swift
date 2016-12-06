
import UIKit

class TFLSlideContainerController: UIViewController {
    var slideOffset : (top:CGFloat,bottom:CGFloat) = (0,160)
    private var yOffset : CGFloat = 0
    fileprivate lazy var shapeLayer : CAShapeLayer = {
        let path = CGMutablePath()
        let radius = CGFloat(20)
        path.move(to: CGPoint(x:radius,y:0))
        path.addLine(to: CGPoint(x:self.view.frame.size.width-radius,y:0))
        
        path.addArc(center: CGPoint(x:self.view.frame.size.width-radius,y:radius), radius: radius, startAngle: CGFloat(1.5 * M_PI), endAngle: 0, clockwise: false)
        path.addLine(to: CGPoint(x:self.view.frame.size.width,y:self.sliderHandleContainerView.frame.size.height))
        path.addLine(to: CGPoint(x:0,y:self.sliderHandleContainerView.frame.size.height))
        path.addLine(to: CGPoint(x:0,y:radius))
        path.addArc(center: CGPoint(x:radius,y:radius), radius: radius, startAngle: CGFloat(M_PI) , endAngle:  CGFloat(1.5 * M_PI), clockwise: false)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path
        return shapeLayer
    }()
    
    @IBOutlet fileprivate weak var effectsView : UIVisualEffectView!
    @IBOutlet fileprivate weak var backgroundContainerView : UIView!
    @IBOutlet fileprivate var sliderContainerView : UIView! = nil
    @IBOutlet fileprivate var sliderHandleContainerView : UIView!
    @IBOutlet fileprivate var sliderContentContainerView : UIView!
    @IBOutlet fileprivate var sliderContainerViewTopConstraint : NSLayoutConstraint!
    @IBOutlet fileprivate var sliderHandleView : UIView! {
        didSet {
            self.sliderHandleView.layer.cornerRadius = self.sliderHandleView.frame.size.height/2
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sliderHandleContainerView.clipsToBounds = true
        self.effectsView.layer.mask  = shapeLayer
    }
    
    
    func setContentControllers(with backgroundController : UIViewController,and sliderController : UIViewController) {
        add(backgroundController,to: backgroundContainerView )
        add(sliderController,to: sliderContentContainerView )
    }
    
    @IBAction func gestureHandler(_ recognizer : UIGestureRecognizer) {
        let p = recognizer.location(in: self.view)
        switch recognizer.state {
        case .began:
            self.yOffset = recognizer.location(in: self.sliderHandleContainerView).y
        case .changed:
            let normalisedOrigin =  p.y - yOffset
            let yOrigin = max(min(normalisedOrigin,self.view.frame.size.height - self.slideOffset.bottom),self.slideOffset.top)
            self.sliderContainerViewTopConstraint.constant = yOrigin
            self.view.layoutIfNeeded()
        case .ended:
            fallthrough
        default:
            break
        }
    }
}

fileprivate extension TFLSlideContainerController {
}

fileprivate extension TFLSlideContainerController {
    func add(_ controller: UIViewController,to containerView: UIView) {
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        addChildViewController(controller)
        containerView.addSubview(controller.view)
        controller.didMove(toParentViewController: self)
        let dict : [String : Any] = ["contentView" : controller.view]
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[contentView]|", options: [], metrics: nil, views: dict)
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[contentView]|", options: [], metrics: nil, views: dict)
        containerView.addConstraints(hConstraints+vConstraints)
    }
}
