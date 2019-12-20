//
//  CountDownLabel.swift
//  CountDownLabel
//
//  Created by Frank Saar on 18/12/2019.
//  Copyright © 2019 Frank Saar. All rights reserved.
//

import UIKit

class CountDownLabel: UIView {
    
    fileprivate var timer : Timer?
    fileprivate lazy var twoDigit10 = countDownElementView()
    fileprivate lazy var twoDigit1 = countDownElementView()
    fileprivate lazy var oneDigit = countDownElementView()
    
    fileprivate var oneDigitValue : String  {
        return "\(self.currentValue % 10)"
    }
    fileprivate var  twoDigitValue : String  {
        let value = self.currentValue / 10
        let returnValue = value == 0 ? "" : "\(value)"
        return returnValue
    }

    var countDownValue : Int = 30 {
        didSet {
            reset()
        }
    }
    fileprivate var currentValue = 30
    
    var textColor : UIColor = .white {
        didSet {
            self.twoDigit10.textColor = textColor
            self.twoDigit1.textColor = textColor
            self.oneDigit.textColor = textColor
        }
    }
    
    var font = UIFont.systemFont(ofSize: 14) {
        didSet {
            self.twoDigit10.font = font
            self.twoDigit1.font = font
            self.oneDigit.font = font
        }
    }
    
    init() {
        super.init(frame: .zero)
        setup()
        reset()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
        reset()
    }
    
    func start() {
        stop()
        self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: animationBlock)
    }
    
    func stop() {
        self.timer?.invalidate()
        self.timer = nil
        reset()
    }
}


//
// MARK: - Helper
//
fileprivate extension CountDownLabel {
    func reset() {
        self.currentValue = self.countDownValue
        self.twoDigit10.text = twoDigitValue
        self.twoDigit1.text =  oneDigitValue
        let value = twoDigitValue.isEmpty ? oneDigitValue : ""
        self.oneDigit.text = value
        self.twoDigit10.isHidden = twoDigitValue.isEmpty ? true : false
        self.twoDigit1.isHidden = self.twoDigit10.isHidden
        self.oneDigit.isHidden = twoDigitValue.isEmpty ? false : true
    }

    func countDownElementView() -> CountDownElementView {
        let view = CountDownElementView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = self.font
        return view
    }
    
    func animationBlock(_ timer : Timer) {
        guard self.currentValue > 0 else {
            self.stop()
            return
        }
        self.currentValue -= 1
        let isTwoDigitToOneDigitTransition = self.currentValue == 9
        let animate2Digits = self.currentValue >= 9
        let animate1Digit = self.currentValue <= 9
        
        self.twoDigit10.isHidden = animate2Digits ? false : true
        self.twoDigit1.isHidden = animate2Digits ? false : true
        self.oneDigit.isHidden = animate1Digit ? false : true
   
        if animate2Digits {
            let new2DigitValue = isTwoDigitToOneDigitTransition ? "" :  self.twoDigitValue
            if new2DigitValue != twoDigit10.text {
                self.twoDigit10.animateWithInterval(0.25,newText: new2DigitValue)
            }
            let new1DigitValue = isTwoDigitToOneDigitTransition ? "" :  self.oneDigitValue
            twoDigit1.animateWithInterval(0.25,newText: new1DigitValue)
        }
        if animate1Digit {
            oneDigit.animateWithInterval(0.25,newText: self.oneDigitValue)
        }
    }
    
    func setup() {
        self.isUserInteractionEnabled = false
        self.clipsToBounds = true
        self.addSubview(self.twoDigit10)
        self.addSubview(self.twoDigit1)
        self.addSubview(self.oneDigit)

        NSLayoutConstraint.activate([
            twoDigit10.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            twoDigit10.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5),
            twoDigit10.topAnchor.constraint(equalTo: self.topAnchor),
            twoDigit10.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            twoDigit1.leadingAnchor.constraint(equalTo: twoDigit10.trailingAnchor),
            twoDigit1.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5),
            twoDigit1.topAnchor.constraint(equalTo: self.topAnchor),
            twoDigit1.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            oneDigit.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            oneDigit.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.5),
            oneDigit.topAnchor.constraint(equalTo: self.topAnchor),
            oneDigit.bottomAnchor.constraint(equalTo: self.bottomAnchor),
        ])
        
    }
}
