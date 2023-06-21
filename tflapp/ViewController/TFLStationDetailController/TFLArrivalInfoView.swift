//
//  TFLArrivalInfoView.swift
//  tflapp
//
//  Created by Frank Saar on 09/01/2019.
//  Copyright © 2019 SAMedialabs. All rights reserved.
//

import UIKit

class TFLArrivalInfoView : UIView {
    static let minTitle = "1 \(NSLocalizedString("Common.min", comment: ""))"
    static let minsTitle = NSLocalizedString("Common.mins", comment: "")

    static let size = CGSize(width:58,height:46)
    fileprivate lazy var vehicleIDLabel : UILabel = {
        let vehicleIDLabel = UILabel(frame: .zero)
        vehicleIDLabel.translatesAutoresizingMaskIntoConstraints = false
        vehicleIDLabel.backgroundColor = UIColor(named: "tflArrivalInfoViewNumberBackgroundColor")
        vehicleIDLabel.textColor = UIColor(named: "tflPrimaryTextColor") ?? .white
        vehicleIDLabel.minimumScaleFactor = 0.5
        vehicleIDLabel.adjustsFontSizeToFitWidth = true
        vehicleIDLabel.numberOfLines = 1
        vehicleIDLabel.textAlignment = .center
        vehicleIDLabel.widthAnchor.constraint(equalToConstant: 44).isActive = true
        vehicleIDLabel.font = .tflStationDetailArrivalInfoVehicleTitle()
        vehicleIDLabel.isAccessibilityElement = false

        return vehicleIDLabel
    }()
    
    fileprivate lazy var timeLabel : TFLAnimatedLabel = {
        let timeLabel = TFLAnimatedLabel(frame: .zero)
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        timeLabel.textColor = UIColor(named: "tflPrimaryTextColor") ?? .white
        timeLabel.backgroundColor = UIColor(named: "tflArrivalInfoViewBackgroundColor")
        timeLabel.textAlignment = .center
        timeLabel.font = .tflStationDetailArrivalInfoTimeTitle()
        timeLabel.widthAnchor.constraint(equalToConstant: TFLArrivalInfoView.size.width - 4).isActive = true
        timeLabel.isAccessibilityElement = false

        return timeLabel
    }()
    
    var timeInSecs : UInt = 0
    var vehicleID : String = ""
    
    
    
    static fileprivate var busArrivalInfoViewBackgroundImage = TFLArrivalInfoView.backgroundImage()
    
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
    
//    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
//        super.traitCollectionDidChange(previousTraitCollection)
//        guard traitCollection.userInterfaceStyle != previousTraitCollection?.userInterfaceStyle else {
//            return
//        }
//        updateColors()
//    }
       
    
}

fileprivate extension TFLArrivalInfoView  {
    static func backgroundImage() -> UIImage {
        let bounds = CGRect(origin:.zero, size: CGSize(width: TFLArrivalInfoView.size.width, height: TFLArrivalInfoView.size.height))
        let numberPlateRect = CGRect(x: 5, y: 4, width: TFLArrivalInfoView.size.width - 10, height: 16)
        let format = UIGraphicsImageRendererFormat()
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(bounds: bounds,format: format)
        return renderer.image { context in
            UIColor(named: "tflBackgroundColor")?.setFill()
            context.fill(bounds)

            let path = UIBezierPath(roundedRect: bounds, cornerRadius: 5)
            UIColor(named: "tflArrivalInfoViewBorderColor")?.setFill()
            path.fill()

            let innerPath = UIBezierPath(roundedRect: bounds.insetBy(dx: 1, dy: 1) , cornerRadius: 5)
            let bgColor = UIColor(named: "tflArrivalInfoViewBackgroundColor")
            bgColor?.setFill()
            innerPath.fill()

            let numberPlateRectPath = UIBezierPath(roundedRect: numberPlateRect , cornerRadius: 0)
            UIColor(named: "tflArrivalInfoViewNumberBackgroundColor")?.setFill()
            UIColor(named: "tflArrivalInfoVIewNumberFieldBorderColor")?.setStroke()
            numberPlateRectPath.lineWidth = 0.5
            numberPlateRectPath.fill()
            numberPlateRectPath.stroke()
        }
    }
    
    func updateColors() {
        vehicleIDLabel.backgroundColor = UIColor(named: "tflArrivalInfoViewNumberBackgroundColor")
        vehicleIDLabel.textColor = UIColor(named: "tflPrimaryTextColor") ?? .white
        timeLabel.textColor = UIColor(named: "tflPrimaryTextColor") ?? .white
        timeLabel.backgroundColor = UIColor(named: "tflArrivalInfoViewBackgroundColor")
        TFLArrivalInfoView.busArrivalInfoViewBackgroundImage = TFLArrivalInfoView.backgroundImage()
        self.layer.contents = TFLArrivalInfoView.busArrivalInfoViewBackgroundImage.cgImage
    }
    
    func arrivalTime(in secs : UInt) -> String {
        var timeString = ""
        
        switch secs {
        case ...60:
            timeString = NSLocalizedString("Common.due", comment: "")
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
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalToConstant: TFLArrivalInfoView.size.width),
            self.heightAnchor.constraint(equalToConstant: TFLArrivalInfoView.size.height),
            self.vehicleIDLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.vehicleIDLabel.topAnchor.constraint(equalTo: self.topAnchor,constant:6),
            self.timeLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.timeLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant:-5),
 
        ])
        updateColors()
    }
}
