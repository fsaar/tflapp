
import UIKit

class TFLSlideContainerController: UIViewController {
    var slideOffset : (top:CGFloat,bottom:CGFloat) = (UIApplication.shared.statusBarFrame.size.height,160)
    var yOffset : CGFloat = 0
    @IBOutlet fileprivate weak var backgroundContainerView : UIView!
     @IBOutlet fileprivate var sliderContainerView : UIView! = nil {
        didSet {
        }
    }
    @IBOutlet fileprivate var sliderHandleContainerView : UIView!
    @IBOutlet fileprivate var sliderContentContainerView : UIView!
    @IBOutlet fileprivate var sliderHandleView : UIView! {
        didSet {
            self.sliderHandleView.layer.cornerRadius = self.sliderHandleView.frame.size.height/2
        }
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
            sliderContainerView.frame.origin.y = max(min(newYOrigin,self.view.frame.size.height - self.slideOffset.bottom + statusBarHeight),self.slideOffset.top)
            updateClipsToBounds()
        default:
            break
        }
    }
}

fileprivate extension TFLSlideContainerController {
    func updateClipsToBounds() {
        self.sliderContainerView.clipsToBounds = sliderContainerView.frame.origin.y == UIApplication.shared.statusBarFrame.size.height ? false : true
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
