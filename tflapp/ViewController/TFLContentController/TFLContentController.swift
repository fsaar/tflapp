import UIKit
import Crashlytics

protocol TFLContentControllerDelegate : class {
    func refresh(controller: TFLContentController, using completionBlock:@escaping ()->())
}

class TFLContentController: UIViewController {
    
    weak var delegate : TFLContentControllerDelegate?
    private enum SegueIdentifier : String {
        case slideContainerController = "TFLSlideContainerControllerSegue"
    }
    fileprivate lazy var mapViewController : TFLMapViewController? = {
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "TFLMapViewController") as? TFLMapViewController else {
            return nil
        }
        return controller
    }()
    
    fileprivate var nearbyBusStationController : TFLNearbyBusStationsController? {
        return self.nearbyBackgroundController?.nearbyBusStationController
    }
    
    fileprivate lazy var nearbyBackgroundController : TFLNearbyBackgroundController? = {
        guard let controller = self.storyboard?.instantiateViewController(withIdentifier: "TFLNearbyBackgroundController") as? TFLNearbyBackgroundController else {
            return nil
        }
        controller.delegate = self
        return controller
    }()
    
    fileprivate var slideContainerController : TFLSlideContainerController?
    
    var busStopPredicationTuple :  [TFLBusStopArrivalsInfo] = [] {
        didSet {
            self.nearbyBusStationController?.busStopPredicationTuple = self.busStopPredicationTuple
            self.mapViewController?.busStopPredicationTuple = self.busStopPredicationTuple
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier , let segueIdentifier = SegueIdentifier(rawValue: identifier) else {
            return
        }
        switch segueIdentifier {
        case .slideContainerController:
            if let slideContainerController = segue.destination as? TFLSlideContainerController {
                self.slideContainerController = slideContainerController
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        Crashlytics.notify()
        if let mapViewController = self.mapViewController, let nearbyBackgroundController = self.nearbyBackgroundController {
            self.slideContainerController?.setContentControllers(with: mapViewController,and: nearbyBackgroundController)
            
            
        }
    }
    
}

// MARK: TFLNearbyBusStationsControllerDelegate

extension TFLContentController : TFLNearbyBusStationsControllerDelegate {
    func refresh(controller: TFLNearbyBusStationsController, using completionBlock:@escaping ()->()) {
        Crashlytics.notify()
        self.delegate?.refresh(controller: self, using: completionBlock)
    }
}
