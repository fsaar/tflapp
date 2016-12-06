
import UIKit

enum TFLSlideContainerControllerState {
    case bottom
    case middle
    case top
    
}

class TFLSlideContainerController: UIViewController {
    var state : TFLSlideContainerControllerState?
    lazy var slideOffset : (top:CGFloat,bottom:CGFloat) = (10,self.effectsViewContainerView.frame.size.height+125)
    private var yOffset : CGFloat = 0
    fileprivate lazy var shapeLayer : CAShapeLayer = {
        let path = CGMutablePath()
        let radius = CGFloat(20)
        path.move(to: CGPoint(x:radius,y:0))
        path.addLine(to: CGPoint(x:self.view.frame.size.width-radius,y:0))
        
        path.addArc(center: CGPoint(x:self.view.frame.size.width-radius,y:radius), radius: radius, startAngle: CGFloat(1.5 * M_PI), endAngle: 0, clockwise: false)
        path.addLine(to: CGPoint(x:self.view.frame.size.width,y:self.effectsViewContainerView.frame.size.height))
        path.addLine(to: CGPoint(x:0,y:self.effectsViewContainerView.frame.size.height))
        path.addLine(to: CGPoint(x:0,y:radius))
        path.addArc(center: CGPoint(x:radius,y:radius), radius: radius, startAngle: CGFloat(M_PI) , endAngle:  CGFloat(1.5 * M_PI), clockwise: false)
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path
        return shapeLayer
    }()
    @IBOutlet fileprivate weak var effectsViewContainerView : UIView!
    @IBOutlet fileprivate weak var backgroundContainerView : UIView!
    @IBOutlet fileprivate var sliderContainerView : UIView! = nil
    @IBOutlet fileprivate var sliderContentContainerView : UIView!
    @IBOutlet fileprivate var sliderContainerViewTopConstraint : NSLayoutConstraint!
    @IBOutlet fileprivate var sliderHandleView : UIView! {
        didSet {
            self.sliderHandleView.layer.cornerRadius = self.sliderHandleView.frame.size.height/2
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.effectsViewContainerView.layer.mask = self.shapeLayer
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.updateState(to: state ?? .top)
    }
    
    func setContentControllers(with backgroundController : UIViewController,and sliderController : UIViewController) {
        add(backgroundController,to: backgroundContainerView )
        add(sliderController,to: sliderContentContainerView )
    }
    
    @IBAction func gestureHandler(_ recognizer : UIGestureRecognizer) {
        let p = recognizer.location(in: self.view)
        switch recognizer.state {
        case .began:
            self.yOffset = recognizer.location(in: self.effectsViewContainerView).y
        case .changed:
            let normalisedOrigin =  p.y - yOffset
            let yOrigin = max(min(normalisedOrigin,self.view.frame.size.height - self.slideOffset.bottom),self.slideOffset.top)
            self.sliderContainerViewTopConstraint.constant = yOrigin
            self.view.layoutIfNeeded()
        case .ended:
            let newState : TFLSlideContainerControllerState = self.state(for: self.sliderContainerViewTopConstraint.constant)
            self.updateState(to: newState, animated: true)
        default:
            break
        }
    }
}

/// MARK: State Handling

fileprivate extension TFLSlideContainerController {
    func updateState(to state: TFLSlideContainerControllerState, animated : Bool = false) {
        self.state = state
        self.sliderContainerViewTopConstraint.constant = topOffset(for: state)
        let duration = animated ? 0.25 : 0.0
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func topOffset(for state: TFLSlideContainerControllerState) -> CGFloat {
        var offset : CGFloat = 0
        switch state {
        case .bottom:
            offset =  self.view.frame.size.height - self.slideOffset.bottom
        case .top:
            offset =  self.slideOffset.top
        case .middle:
            offset =  self.view.frame.size.height/3
        }
        return offset
    }
    
    
    func state(for topOffset: CGFloat) -> TFLSlideContainerControllerState {
        var state : TFLSlideContainerControllerState = .middle
        let height = self.view.frame.size.height
        switch topOffset {
        case 0..<height/4:
            state = .top
        case height/4..<(5*height/8):
            state = .middle
        default:
            state = .bottom
        }
        return state
    }

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
