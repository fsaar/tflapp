//
//  TFLCircleAnimationView.swift
//  tflapp
//
//  Created by Frank Saar on 19/11/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//

import UIKit
import Foundation

class TFLCircleAnimationView : UIView {
    fileprivate enum State {
        case active
        case inactive
    }
    
    fileprivate var state = State.inactive
    fileprivate lazy var animView = self.animationView()
    fileprivate lazy var animView2 = self.animationView()
    fileprivate lazy var animView3 = self.animationView()
    fileprivate lazy var animViews : [UIView] = [self.animView,self.animView2,self.animView3]

    fileprivate let animator1 = UIViewPropertyAnimator(duration: 4.0, curve: UIView.AnimationCurve.easeOut)
    fileprivate let animator2 = UIViewPropertyAnimator(duration: 4.0, curve: UIView.AnimationCurve.easeOut)
    fileprivate let animator3 = UIViewPropertyAnimator(duration: 4.0, curve: UIView.AnimationCurve.easeOut)
    
    fileprivate var isRunning : Bool {
        return state == .active
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    deinit {
        stopAnimation()
    }
   
    func startAnimation() {
        state = .active
        isHidden = false
        animate(animator1,animView) { [weak self] in
            self?.completionBlock(self?.animator1,self?.animView)
        }
        animate(animator2,animView2,delay: 1.33)  { [weak self] in
            self?.completionBlock(self?.animator2,self?.animView2)
        }
        animate(animator3,animView3,delay: 2.66)  { [weak self] in
            self?.completionBlock(self?.animator3,self?.animView3)
        }
        
    }
   
    func stopAnimation() {
        isHidden = true
        state = .inactive
        animator1.stopAnimation(true)
        animator2.stopAnimation(true)
        animator3.stopAnimation(true)
        resetViews()
    }
}

fileprivate extension TFLCircleAnimationView {
    func resetViews() {
        animViews.forEach { view in
            view.alpha = 1.0
            view.transform = CGAffineTransform.identity.scaledBy(x: 0.3, y: 0.3)
        }
        self.sendSubviewToBack(animView2)
        self.sendSubviewToBack(animView3)
    }
    
    @MainActor
    func completionBlock(_ animator : UIViewPropertyAnimator?,_ view : UIView?) {
        guard let animator = animator,let view = view else {
            return
        }
        
        guard self.state == .active else {
            return
        }
        self.animate(animator,view) {
            self.completionBlock(animator, view)
        }
        
    }
    
    
    func animate(_ animator : UIViewPropertyAnimator,_ v : UIView,delay : TimeInterval = 0,using comletionBlock:@escaping ()->Void) {
        animator.addAnimations({
            v.transform = .identity
        }, delayFactor: 0.0)
        
        animator.addAnimations({
            v.alpha = 0
        }, delayFactor: 0.5)
        
        animator.addCompletion { _ in
            v.superview?.bringSubviewToFront(v)
            v.transform = CGAffineTransform.identity.scaledBy(x: 0.3, y: 0.3)
            v.alpha = 1
            comletionBlock()
        }
        
        animator.startAnimation(afterDelay: delay)
    }
    
    
    func setup() {
        self.backgroundColor = .clear
        self.isHidden = true
        animViews.reversed().forEach { view in
            self.addSubview(view)
            NSLayoutConstraint.activate([
                view.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                view.centerYAnchor.constraint(equalTo: self.centerYAnchor),
                ])
        }
    }
    
    func animationView() -> UIView  {
        let radius : CGFloat = 28
        let animView = UIView(frame: .zero)
        animView.translatesAutoresizingMaskIntoConstraints = false
        animView.widthAnchor.constraint(equalToConstant: 2 * radius).isActive = true
        animView.heightAnchor.constraint(equalToConstant: 2 * radius).isActive = true
        animView.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.9, alpha: 0.8)
        animView.layer.cornerRadius = radius
        animView.layer.borderColor = UIColor.white.withAlphaComponent(0.7).cgColor
        animView.layer.borderWidth = 1.0
        animView.layer.masksToBounds = true
        animView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
        return animView
    }
}
