//
//  TFLArrivalInfoView.swift
//  tflapp
//
//  Created by Frank Saar on 09/01/2019.
//  Copyright © 2019 SAMedialabs. All rights reserved.
//

import UIKit

class TFLArrivalInfoView : UIView {
    static let minTitle = "1 \(NSLocalizedString("TFLArrivalInfoView.min", comment: ""))"
    static let minsTitle = NSLocalizedString("TFLArrivalInfoView.mins", comment: "")

    static let size = CGSize(width:58,height:46)
    fileprivate lazy var vehicleIDLabel : UILabel = {
        let vehicleIDLabel = UILabel(frame: .zero)
        vehicleIDLabel.translatesAutoresizingMaskIntoConstraints = false
        vehicleIDLabel.backgroundColor = UIColor.yellow
        vehicleIDLabel.textColor = .black
        vehicleIDLabel.minimumScaleFactor = 0.5
        vehicleIDLabel.numberOfLines = 1
        vehicleIDLabel.textAlignment = .center
        vehicleIDLabel.font = .tflStationDetailArrivalInfoVehicleTitle()
        return vehicleIDLabel
    }()
    
    fileprivate lazy var timeLabel : TFLAnimatedLabel = {
        let timeLabel = TFLAnimatedLabel(frame: .zero)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.textColor = .black
        timeLabel.backgroundColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
        timeLabel.textAlignment = .center
        timeLabel.font = .tflStationDetailArrivalInfoTimeTitle()
        timeLabel.widthAnchor.constraint(equalToConstant: TFLArrivalInfoView.size.width - 4)
        return timeLabel
    }()
    
    var timeInSecs : UInt = 0
    var vehicleID : String = ""
    
    static fileprivate var busArrivalInfoViewBackgroundImage: UIImage = {
        let bounds = CGRect(origin:.zero, size: CGSize(width: TFLArrivalInfoView.size.width, height: TFLArrivalInfoView.size.height))
        let nubmerPlateRect = CGRect(x: 6, y: 4, width: TFLArrivalInfoView.size.width - 12, height: 16)
        let format = UIGraphicsImageRendererFormat()
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(bounds: bounds,format: format)
        return renderer.image { context in
            UIColor.white.setFill()
            context.fill(bounds)
            
            let path = UIBezierPath(roundedRect: bounds, cornerRadius: 5)
            UIColor.red.setFill()
            path.fill()
            
            let innerPath = UIBezierPath(roundedRect: bounds.insetBy(dx: 1, dy: 1) , cornerRadius: 5)
            let bgColor = UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
            bgColor.setFill()
            innerPath.fill()
            
            let numberPlateRectPath = UIBezierPath(roundedRect: nubmerPlateRect , cornerRadius: 0)
            UIColor.yellow.setFill()
            UIColor.black.setStroke()
            numberPlateRectPath.lineWidth = 0.5
            numberPlateRectPath.fill()
            numberPlateRectPath.stroke()
            
        }
    }()
    
    override init(frame : CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func configure(with numberPlate: String, and timeinSecs : UInt,animated : Bool) {
        let timeInSecs = arrivalTime(in: timeinSecs)
        self.timeLabel.setText(timeInSecs, animated: animated)
        self.vehicleIDLabel.text = numberPlate
    }
    
}

fileprivate extension TFLArrivalInfoView  {
    func arrivalTime(in secs : UInt) -> String {
        var timeString = ""
        
        switch secs {
        case ...60:
            timeString = NSLocalizedString("TFLArrivalInfoView.due", comment: "")
        default:
            let mins = secs/60
            timeString = "\(mins) \(TFLArrivalInfoView.minsTitle)"
            if mins == 1 {
                timeString = TFLArrivalInfoView.minTitle
            }
        }
        return timeString
    }
    
    func setup() {
        self.addSubview(vehicleIDLabel)
        self.addSubview(timeLabel)
        self.layer.contents = TFLArrivalInfoView.busArrivalInfoViewBackgroundImage.cgImage
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: TFLArrivalInfoView.size.width),
            self.heightAnchor.constraint(equalToConstant: TFLArrivalInfoView.size.height),
            self.vehicleIDLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.vehicleIDLabel.topAnchor.constraint(equalTo: self.topAnchor,constant:6),
            self.timeLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.timeLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant:-5),
 
        ])
        
    }
}
