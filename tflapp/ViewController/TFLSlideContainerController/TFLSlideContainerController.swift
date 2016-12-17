
import UIKit

class TFLSlideContainerController: UIViewController {
    var snapPositions: [CGFloat] = [0.01,0.4,0.75]
    fileprivate var snapHandler : TFLSnapHandler?
    var sliderViewUpdateBlock : ((_ slider : UIView,_ origin: CGPoint,_ final : Bool) -> ())? = nil {
        didSet {
            self.sliderViewUpdateBlock?(self.sliderContainerView, self.sliderContainerView.frame.origin, true)
        }
    }
    
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
    @IBOutlet fileprivate weak var sliderHandleContainerView : UIView!
    @IBOutlet fileprivate weak var sliderHandleBackgroundView : UIView!
    @IBOutlet fileprivate weak var backgroundContainerView : UIView!
    @IBOutlet fileprivate var sliderContainerView : UIView! = nil
    @IBOutlet fileprivate var sliderContentContainerView : UIView!
    @IBOutlet fileprivate var sliderContainerViewTopConstraint : NSLayoutConstraint!
    @IBOutlet fileprivate var sliderHandleView : UIView! {
        didSet {
            self.sliderHandleView.layer.cornerRadius = self.sliderHandleView.frame.size.height/2
        }
    }
  
    func updateSliderContainerView(with position: CGPoint, animated : Bool, final : Bool) {
        self.sliderContainerViewTopConstraint.constant = position.y
        if (animated) {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
        else
        {
            self.view.layoutIfNeeded()
        }
        self.sliderViewUpdateBlock?(view,position,final)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.sliderHandleBackgroundView.layer.mask = self.shapeLayer
        self.snapHandler = TFLSnapHandler(with: self.sliderHandleContainerView,in: self.view, and: self.snapPositions, using: { [weak self] _,newOrigin,final in
            self?.updateSliderContainerView(with: newOrigin, animated: final, final: final)
        })
        let initPositionY = (self.snapPositions.first ?? 0) * self.view.frame.size.height
        self.updateSliderContainerView(with: CGPoint(x:self.sliderContainerView.frame.origin.x,y:initPositionY), animated: false, final: true)
    }
    
    
    func setContentControllers(with backgroundController : UIViewController,and sliderController : UIViewController) {
        add(backgroundController,to: backgroundContainerView )
        add(sliderController,to: sliderContentContainerView )
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
