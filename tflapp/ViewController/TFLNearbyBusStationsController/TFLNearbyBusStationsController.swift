import UIKit
import SwiftUI
import CoreLocation

class TFLNearbyBusStationsController : UIViewController {
   
   
    var arrivalsInfo :  [TFLBusStopArrivalsInfo] = [] {
        didSet {
            let busStopArrivalViewModels = Set(arrivalsInfo).sortedByBusStopDistance().map{ TFLBusStopArrivalsViewModel(with: $0) }
            let list = busStopArrivalViewModels.map { TFLBusStationInfo($0) }
            stationList.list = list
        }
    }
    var stationList = StationList()
    private lazy var nearbyBusStationView = {
        var stationView = TFLNearbyBusStationListView(stationInfoList: self.stationList)
        return stationView
    }()
       
    var currentUserCoordinate = kCLLocationCoordinate2DInvalid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let vc = UIHostingController(rootView: nearbyBusStationView)
        self.addController(vc)
    }
    
    func updateColors() {
//        self.ackLabel.backgroundColor = UIColor(named: "tflBackgroundColor")
//        self.lastUpdatedLabel.backgroundColor = UIColor(named: "tflBackgroundColor")
//        self.ackLabel.textColor = UIColor(named: "tflPrimaryTextColor")
//        self.lastUpdatedLabel.textColor = UIColor(named: "tflPrimaryTextColor")
//        self.view.backgroundColor = UIColor(named: "tflBackgroundColor")
//        self.tableView.reloadData()
        
    }
}
