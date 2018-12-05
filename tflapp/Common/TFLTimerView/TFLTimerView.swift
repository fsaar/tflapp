//
//  TFLTimerView.swift
//  TFLTimerView
//
//  Created by Frank Saar on 02/12/2018.
//  Copyright © 2018 Samedialabs. All rights reserved.
//

import Foundation
import UIKit

protocol TFLTimerViewDelegate : class {
    func tflTimerViewDidExpire(_ timerView : TFLTimerView)
}

class TFLTimerView : UIView {
    fileprivate class DisplayLinkTarget {
        let block : () -> Void
        init (using block : @escaping ()-> Void) {
            self.block = block
        }
        @objc func ticker(_ displayLink : CADisplayLink) {
            block()
        }
    }
    
    weak var delegate : TFLTimerViewDelegate?
    fileprivate let length : CGFloat = 40
    fileprivate let defaultStopAnimationTime = Double(0.25)
    @IBInspectable fileprivate var expiryTime : Int = 60
    fileprivate enum State {
        case running(startDate : Date,expiryDate : Date,timeInSecs: Int)
        case stopped
    }
    fileprivate var state = State.stopped {
        didSet {
            guard case .stopped = state else {
                return
            }
            self.displayLink?.invalidate()
        }
    }
    fileprivate var displayLink : CADisplayLink?
    fileprivate lazy var timerButton : UIButton = {
       let button = UIButton(frame: .zero)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.white, for: .normal)
        button.setTitleColor(.gray, for: .highlighted)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.titleLabel?.textAlignment = .center
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        button.addTarget(self, action: #selector(self.timerButtonHandler(_:)), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var innerLayer : CAShapeLayer = {
        let lineWidth : CGFloat = 4
        let shapeLayer = self.shapeLayer(radius: 14)
        shapeLayer.lineWidth = lineWidth
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = UIColor(red: 100, green: 0, blue: 0, alpha: 0.8).cgColor
        return shapeLayer
    }()
    
    fileprivate lazy var borderLayer : CAShapeLayer = {
        let lineWidth : CGFloat = 6
        let shapeLayer = self.shapeLayer(radius: 14)
        shapeLayer.lineWidth = lineWidth
        shapeLayer.fillColor = self.backgroundColor?.cgColor
        shapeLayer.strokeColor = UIColor.white.cgColor
        return shapeLayer
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
        guard case .stopped = state else {
            return
        }
        let now = Date()
        let expiryDate = now.addingTimeInterval(Double(expiryTime))
        self.state = State.running(startDate : now,expiryDate: expiryDate,timeInSecs: expiryTime)
        let target = DisplayLinkTarget { [animateCountDown] in
            animateCountDown()
        }
        displayLink = CADisplayLink(target: target, selector: #selector(target.ticker(_:)))
        displayLink?.add(to: RunLoop.current, forMode: RunLoop.Mode.common)
    }
    
    func stop(animated : Bool = true) {
        guard case let .running(_,_,timeInSecs) = state else {
            return
        }
        guard animated else {
            self.state = .stopped
            self.borderLayer.strokeEnd = 0
            self.innerLayer.strokeEnd = 0
            return
        }
        guard let percent = expiryInPercent(with: self.state) else {
            return
        }
        let now = Date()
        let timeExpired = defaultStopAnimationTime * (1 - percent)
        let timeLeft = defaultStopAnimationTime - timeExpired
        let newStartTime = now.addingTimeInterval(-timeExpired)
        let newExpiryTime = now.addingTimeInterval(timeLeft)
        self.state = State.running(startDate: newStartTime, expiryDate: newExpiryTime, timeInSecs: timeInSecs)
    }
    
    func reset() {
        self.state = .stopped
        self.timerButton.setTitle("\(expiryTime)", for: .normal)
        self.borderLayer.strokeEnd = 1
        self.innerLayer.strokeEnd = 1
    }
    
    @objc func timerButtonHandler(_ button : UIButton) {
        stop()
    }
}

// MARK: Private

fileprivate extension TFLTimerView {

    func setup() {
        self.widthAnchor.constraint(equalToConstant: length).isActive = true
        self.heightAnchor.constraint(equalToConstant: length).isActive = true
        self.layer.addSublayer(self.borderLayer)
        self.layer.addSublayer(self.innerLayer)
        self.addSubview(self.timerButton)
        NSLayoutConstraint.activate([
            self.timerButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            self.timerButton.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        self.timerButton.setTitle("\(expiryTime)", for: .normal)
        
        self.clipsToBounds = true
        self.layer.cornerRadius = length / 2
        
    
    }
    
    
    func shapeLayer(radius : CGFloat) -> CAShapeLayer {
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = self.bounds
        let center = CGPoint(x: self.frame.size.width / 2.0, y: self.frame.size.height / 2.0)
        let bezierPath = UIBezierPath(arcCenter: center, radius: radius , startAngle: 0, endAngle: CGFloat(2 * Double.pi * 0.91), clockwise: true)
        shapeLayer.path = bezierPath.cgPath
        shapeLayer.position = CGPoint(x:20,y:20)
        shapeLayer.transform = CATransform3DRotate(CATransform3DIdentity, CGFloat(-Double.pi / 2), 0, 0, 1.0)
        shapeLayer.lineCap = .round

        return shapeLayer
    }
    
    func expiryInPercent(with state: State) -> Double? {
        let now = Date()
        guard case let State.running(startTime,expiryTime,_) = state else {
            return nil
        }
        let secs = expiryTime.timeIntervalSince1970 - startTime.timeIntervalSince1970
        let secsPassed = -now.timeIntervalSince(expiryTime)
        let percent = (secsPassed / secs)
        return percent
    }
    
    func animateCountDown() {
        let now = Date()
        guard case let State.running(_,expiryTime,timeInSecs) = state else {
            return
        }
        guard now < expiryTime, let percent = expiryInPercent(with: self.state) else {
            self.delegate?.tflTimerViewDidExpire(self)
            state = .stopped
            return
        }
        let timeLeft = Int(Double(timeInSecs) * percent) + 1
        self.timerButton.setTitle("\(timeLeft)", for: .normal)


        self.borderLayer.strokeEnd = CGFloat(percent)
        self.innerLayer.strokeEnd = CGFloat(percent)
    }
}
