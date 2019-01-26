//
//  TFLDroppingBallView.swift
//  test2
//
//  Created by Frank Saar on 25/01/2019.
//  Copyright © 2019 Samedialabs. All rights reserved.
//

import UIKit

class TFLDroppingBallView : UIView {
    var ball : UIView = {
        let ball = UIView(frame:.zero)
        ball.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            ball.widthAnchor.constraint(equalToConstant: 10),
            ball.heightAnchor.constraint(equalToConstant: 10)
            ])
        ball.backgroundColor = UIColor.red
        ball.isHidden = true
        ball.clipsToBounds = true
        ball.layer.cornerRadius = 5
        return ball
    }()
    fileprivate lazy var heightConstraint : NSLayoutConstraint = {
        let heightConstraint = self.ball.centerYAnchor.constraint(equalTo: self.topAnchor, constant: 0)
        return heightConstraint
    }()
    
    fileprivate lazy var animator : UIViewPropertyAnimator = {
        let animator = UIViewPropertyAnimator(duration: 2, curve: .linear)
        return animator
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func startAnimation() {
        ball.isHidden = false
        animator.addAnimations {
            self.heightConstraint.constant = self.frame.size.height
            self.layoutIfNeeded()
        }
        animator.addCompletion { [weak self] _ in
            self?.heightConstraint.constant = 0
            self?.ball.layoutIfNeeded()
            OperationQueue.main.addOperation {
                self?.startAnimation()
            }
        }
        animator.startAnimation()
    }
    
    func stopAnimation() {
        animator.stopAnimation(true)
        ball.isHidden = true
        self.heightConstraint.constant = 0
        self.layoutIfNeeded()
    }
    
}

fileprivate extension TFLDroppingBallView {
    func setup() {
        self.addSubview(ball)
        self.backgroundColor = .clear
        NSLayoutConstraint.activate([
            ball.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            heightConstraint
            ])
    }
}
