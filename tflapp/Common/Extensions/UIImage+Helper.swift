//
//  UIImage + Helper
//  tflapp
//
//  Created by Frank Saar on 03/11/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//

import UIKit
import MapKit

extension UIImage {

    static func imageForPos(_ pos : CLLocationCoordinate2D,using completionBlock: @escaping (_ image : UIImage?) -> Void)  {
        let mapSnapshotOptions = MKMapSnapshotter.Options()
        
        let location = CLLocationCoordinate2DMake(pos.latitude, pos.longitude)
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 100, longitudinalMeters: 100)
        mapSnapshotOptions.region = region
        
        // Set the scale of the image. We'll just use the scale of the current device, which is 2x scale on Retina screens.
        mapSnapshotOptions.scale = UIScreen.main.scale
        
        // Set the size of the image output.
        mapSnapshotOptions.size = CGSize(width:300,height: 300)
        
        // Show buildings and Points of Interest on the snapshot
        mapSnapshotOptions.showsBuildings = true
        mapSnapshotOptions.showsPointsOfInterest = true
        
        let snapShotter = MKMapSnapshotter(options: mapSnapshotOptions)
        snapShotter.start { snapshot,_ in
            let image = snapshot?.image
            completionBlock(image)
        }
    }

}
