//
//  TFLDebugUtility.swift
//  tflapp
//
//  Created by Frank Saar on 04/11/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//

import UIKit
import MapKit

class TFLDebugUtility {
    private let debugView : UIView
    
    init(with debugView: UIView) {
        self.debugView = debugView
    }
    
    func showImageForPos(_ pos : CLLocationCoordinate2D,_ text : String? = nil) {
        UIImage.imageForPos(pos,nil) { [weak self] image in
            if let image = image {
                self?.showImage(image)
            }
        }
    }
}

// MARK: Helper Methods

private extension TFLDebugUtility {
    func imageView(with image : UIImage) -> UIImageView {
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        imageView.layer.borderColor = UIColor.red.cgColor
        imageView.layer.borderWidth = 2.0
        imageView.isUserInteractionEnabled = true
        return imageView
    }
    
    
    func showImage(_ image : UIImage) {
        let imageView = self.imageView(with: image)
        self.debugView.addSubview(imageView)
        
        let tapHandler = UITapGestureRecognizer(target: self, action: #selector(self.hideImageView(_:)))
        imageView.addGestureRecognizer(tapHandler)
        
        UIView.animate(withDuration: 0.5) {
            imageView.transform = CGAffineTransform.identity
        }
        
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: self.debugView.centerXAnchor),
            imageView.bottomAnchor.constraint(equalTo: self.debugView.bottomAnchor,constant:-40),
            imageView.widthAnchor.constraint(equalToConstant: 200),
            imageView.heightAnchor.constraint(equalToConstant: 200)
            ])
    }
    
    @objc func hideImageView(_ gestureRecogniser : UITapGestureRecognizer) {
        guard let imageView = gestureRecogniser.view else {
            return
        }
        let translateTransform = CGAffineTransform(translationX: -UIScreen.main.bounds.width, y: -UIScreen.main.bounds.height)
        let rotateTransform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 359 / 360))
        let transform = translateTransform.concatenating(rotateTransform)
        UIView.animate(withDuration: 1.0,animations: {
            imageView.transform = transform
            
        }) { _ in
            imageView.removeFromSuperview()
            
        }
    }
}
