//
//  TFLStationDetailController.swift
//  tflapp
//
//  Created by Frank Saar on 29/05/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//

import UIKit
import Foundation
import MapKit
import CoreData

class TFLStationDetailMapViewController: UIViewController {
    @IBOutlet weak var mapView : MKMapView!
    
    var viewModels : [TFLStationDetailMapViewModel] = []
}
