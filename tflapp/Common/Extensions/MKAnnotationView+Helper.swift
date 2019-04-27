import MapKit


extension MKAnnotationView {
    
    func animateCurrentPosition() {
        UIView.animateKeyframes(withDuration: 1.0, delay: 0, options:[], animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.5) {
                self.transform = CGAffineTransform.identity.scaledBy(x: 1.5, y: 1.5)
            }
            UIView.addKeyframe(withRelativeStartTime: 0.25, relativeDuration: 0.25) {
                self.transform =  self.transform.rotated(by: CGFloat(-Double.pi / 8))
            }
            UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.25) {
                self.transform = self.transform.rotated(by: CGFloat(Double.pi / 4))
            }
            UIView.addKeyframe(withRelativeStartTime: 0.75, relativeDuration: 0.25) {
                self.transform =  self.transform.rotated(by: CGFloat(-Double.pi / 8))
            }
        }) { _ in
            UIView.animate(withDuration: 0.25,delay: 0, options: [.curveEaseIn],  animations: {
                self.transform = .identity
            },completion: nil)
        }
    }
}
