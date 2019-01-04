//
//  TFLTimerButton.swift
//  TFLTimerButton
//
//  Created by Frank Saar on 02/12/2018.
//  Copyright © 2018 Samedialabs. All rights reserved.
//

import Foundation
import UIKit

protocol TFLTimerButtonDelegate : class {
    func tflTimerViewDidExpire(_ timerView : TFLTimerButton)
}

class TFLTimerButton : UIButton {
    fileprivate class DisplayLinkTarget {
        let block : () -> Void
        init (using block : @escaping ()-> Void) {
            self.block = block
        }
        @objc func ticker(_ displayLink : CADisplayLink) {
            block()
        }
    }
    
    weak var delegate : TFLTimerButtonDelegate?
    fileprivate let length : CGFloat = 40
    fileprivate let radius : CGFloat = 12
    fileprivate let innerWidth : CGFloat = 3
    fileprivate let outerWidth : CGFloat = 5
    fileprivate let defaultStopAnimationTime = Double(0.25)
    @IBInspectable fileprivate var expiryTime : Int = 60
    fileprivate enum DisplayLinkState {
        case running(startDate : Date,expiryDate : Date,timeInSecs: Int)
        case stopped
    }
    fileprivate var displayLinkState = DisplayLinkState.stopped {
        didSet {
            guard case .stopped = displayLinkState else {
                return
            }
            self.displayLink?.invalidate()
        }
    }
    fileprivate var displayLink : CADisplayLink?
    
    fileprivate lazy var innerLayer : CAShapeLayer = {
        let lineWidth : CGFloat = innerWidth
        let shapeLayer = self.shapeLayer(radius: radius,endAngle: CGFloat(2 * Double.pi * 0.92))
        shapeLayer.lineWidth = lineWidth
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor(red: 1, green: 0, blue: 0, alpha: 0.8).cgColor
        return shapeLayer
    }()
    
    fileprivate lazy var borderLayer : CAShapeLayer = {
        let lineWidth : CGFloat = outerWidth
        let shapeLayer = self.shapeLayer(radius: radius,endAngle: CGFloat(2 * Double.pi * 0.92))
        shapeLayer.lineWidth = lineWidth
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor.white.cgColor
        return shapeLayer
    }()
    
    fileprivate lazy var circleBackgroundImage : UIImage = {
        let bounds = CGRect(origin:.zero, size: CGSize(width: length, height: length))
        let format = UIGraphicsImageRendererFormat()
        format.opaque = false
        let renderer = UIGraphicsImageRenderer(bounds: bounds,format: format)
        return renderer.image { context in
            UIColor.clear.setFill()
            context.fill(bounds)
            
            let center = CGPoint(x: length / 2.0, y: length / 2.0)
            let bezierPath = UIBezierPath(arcCenter: center, radius: radius , startAngle: 0, endAngle: CGFloat(2 * Double.pi), clockwise: true)
            UIColor.white.setStroke()
            bezierPath.lineWidth = outerWidth
            bezierPath.stroke()
            
            let bezierPath2 = UIBezierPath(arcCenter: center, radius: radius , startAngle: 0, endAngle: CGFloat(2 * Double.pi), clockwise: true)
            UIColor.lightGray.setStroke()
            bezierPath2.lineWidth = innerWidth
            bezierPath2.stroke()
        }
    }()

    init(expiryTimeInSecods : Int) {
        self.expiryTime = expiryTimeInSecods
        super.init(frame: .zero)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    deinit {
        self.displayLink?.invalidate()
    }
    
    func start() {
        stop(animated: false)
        guard case .stopped = displayLinkState else {
            return
        }
        let now = Date()
        let expiryDate = now.addingTimeInterval(Double(expiryTime))
        self.displayLinkState = .running(startDate : now,expiryDate: expiryDate,timeInSecs: expiryTime)
        let target = DisplayLinkTarget { [animateCountDown] in
            animateCountDown()
        }
        displayLink = CADisplayLink(target: target, selector: #selector(target.ticker(_:)))
        displayLink?.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
    }
    
    func stop(animated : Bool = true) {
        guard case let .running(_,_,timeInSecs) = displayLinkState else {
            return
        }
        guard animated else {
            self.displayLinkState = .stopped
            self.borderLayer.strokeEnd = 0
            self.innerLayer.strokeEnd = 0
            return
        }
        guard let percent = expiryInPercent(with: self.displayLinkState) else {
            return
        }
        let now = Date()
        let timeExpired = defaultStopAnimationTime * (1 - percent)
        let timeLeft = defaultStopAnimationTime - timeExpired
        let newStartTime = now.addingTimeInterval(-timeExpired)
        let newExpiryTime = now.addingTimeInterval(timeLeft)
        self.displayLinkState = .running(startDate: newStartTime, expiryDate: newExpiryTime, timeInSecs: timeInSecs)
    }
    
    func reset() {
        self.displayLinkState = .stopped
        self.setTitle("\(expiryTime)", for: .normal)
        self.borderLayer.strokeEnd = 1
        self.innerLayer.strokeEnd = 1
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: length, height: length)
    }
    
    @objc func tapHandler(_ button : UIButton) {
        stop()
    }
}

// MARK: Private

fileprivate extension TFLTimerButton {

    func setup() {
        self.layer.contents = self.circleBackgroundImage.cgImage
        self.layer.addSublayer(self.borderLayer)
        self.layer.addSublayer(self.innerLayer)
        self.layer.cornerRadius = length / 2
        self.clipsToBounds = true

        self.setTitle("\(expiryTime)", for: .normal)
        self.setTitleColor(.white, for: .normal)
        self.setTitleColor(.gray, for: .highlighted)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 11)
        self.titleLabel?.textAlignment = .center
        self.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.addTarget(self, action: #selector(self.tapHandler(_:)), for: .touchUpInside)
    }
    
    
    func shapeLayer(radius : CGFloat,endAngle : CGFloat) -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = self.bounds
        let center = CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height / 2.0)
        let bezierPath = UIBezierPath(arcCenter: center, radius: radius , startAngle: 0, endAngle: endAngle, clockwise: true)
        shapeLayer.path = bezierPath.cgPath
        shapeLayer.position = CGPoint(x:length / 2,y:length / 2)
        shapeLayer.transform = CATransform3DRotate(CATransform3DIdentity, CGFloat(-Double.pi / 2), 0, 0, 1.0)
        shapeLayer.lineCap = .round
        return shapeLayer
    }
    
    func expiryInPercent(with state: DisplayLinkState) -> Double? {
        let now = Date()
        guard case let .running(startTime,expiryTime,_) = state else {
            return nil
        }
        let secs = expiryTime.timeIntervalSince1970 - startTime.timeIntervalSince1970
        let secsPassed = -now.timeIntervalSince(expiryTime)
        let percent = (secsPassed / secs)
        return percent
    }
    
    func animateCountDown() {
        let now = Date()
        guard case let .running(_,expiryTime,timeInSecs) = displayLinkState else {
            return
        }
        guard now < expiryTime, let percent = expiryInPercent(with: self.displayLinkState) else {
            self.delegate?.tflTimerViewDidExpire(self)
            displayLinkState = .stopped
            return
        }
        let timeLeft = Int(Double(timeInSecs) * percent) + 1
        self.setTitle("\(timeLeft)", for: .normal)


        self.borderLayer.strokeEnd = CGFloat(percent)
        self.innerLayer.strokeEnd = CGFloat(percent)
    }
}
