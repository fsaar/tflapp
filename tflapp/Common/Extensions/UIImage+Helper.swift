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

    static func imageForPos(_ pos : CLLocationCoordinate2D,_ text : String? = nil,using completionBlock: @escaping (_ image : UIImage?) -> Void)  {
        
        let mapSnapshotOptions = MKMapSnapshotter.Options()
        
        let location = CLLocationCoordinate2DMake(pos.latitude, pos.longitude)
        let region = MKCoordinateRegion(center: location, latitudinalMeters: 300, longitudinalMeters: 300)
        mapSnapshotOptions.region = region
        mapSnapshotOptions.scale = UIScreen.main.scale
        mapSnapshotOptions.size = CGSize(width:300,height: 300)
        mapSnapshotOptions.showsBuildings = true
        mapSnapshotOptions.showsPointsOfInterest = true
 
        let snapShotter = MKMapSnapshotter(options: mapSnapshotOptions)
        snapShotter.start { snapshot,_ in
            guard let image = snapshot?.image else {
                completionBlock(nil)
                return
            }
            let render = UIGraphicsImageRenderer(bounds: CGRect(origin: .zero, size: image.size) ,format: UIGraphicsImageRendererFormat())
            let newImage = render.image { _ in
                image.draw(at: .zero)
                
                let bounds = CGRect(origin: CGPoint(x:image.size.width / 2,y:image.size.height / 2 ), size: CGSize(width: 10, height: 10))
                let borderPath = UIBezierPath(roundedRect: bounds , cornerRadius: bounds.size.height/2)
                UIColor.red.setFill()
                borderPath.fill()
                if let text = text {
                    let attributedString = NSAttributedString(string: text)
                    attributedString.draw(at: CGPoint(x:10,y:image.size.height-20))
                }
            }
            completionBlock(newImage)
        }
    
    }

}
