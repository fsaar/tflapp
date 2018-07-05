
import UIKit

class TFLNearbyBackgroundController: UIViewController {
    private enum SegueIdentifier : String {
        case nearbyBusStationController = "TFLNearbyBusStationsControllerSegue"
    }

    @IBOutlet weak var ackLabel : UILabel! = nil {
        didSet {
            self.ackLabel.font = UIFont.tflFontPoweredBy()
            self.ackLabel.text = NSLocalizedString("TFLRootViewController.ackTitle", comment: "")
            self.ackLabel.textColor = .black
        }
    }

    weak var delegate : TFLNearbyBusStationsControllerDelegate? = nil {
        didSet {
            self.nearbyBusStationController?.delegate = self.delegate
        }
    }

    public private(set) var nearbyBusStationController : TFLNearbyBusStationsController?


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier , let segueIdentifier = SegueIdentifier(rawValue: identifier) else {
            return
        }
        switch segueIdentifier {
        case .nearbyBusStationController:
            if let nearbyBusStationController = segue.destination as? TFLNearbyBusStationsController {
                self.nearbyBusStationController = nearbyBusStationController
            }
        }
    }



}
