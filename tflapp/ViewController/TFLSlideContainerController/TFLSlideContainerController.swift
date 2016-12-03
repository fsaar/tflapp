
import UIKit

class TFLSlideContainerController: UIViewController {
    var bottomSlideOffset : CGFloat = 160
    var topSlideOffset : CGFloat = UIApplication.shared.statusBarFrame.size.height
    var yOffset : CGFloat = 0
    @IBOutlet weak var backgroundContainerView : UIView!
    var recognizer : UIPanGestureRecognizer?
    @IBOutlet var sliderContainerView : UIView!
    @IBOutlet var sliderHandleContainerView : UIView!
    @IBOutlet var sliderContentContainerView : UIView!
    @IBOutlet var sliderHandleView : UIView! {
        didSet {
            self.sliderHandleView.layer.cornerRadius = self.sliderHandleView.frame.size.height/2
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            let statusBarHeight = UIApplication.shared.statusBarFrame.size.height
            let newYOrigin =  p.y - yOffset
            sliderContainerView.frame.origin.y = max(min(newYOrigin,self.view.frame.size.height - self.bottomSlideOffset + statusBarHeight),self.topSlideOffset)
        default:
            break
        }
    }
}

extension TFLSlideContainerController  : UIGestureRecognizerDelegate{
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
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
