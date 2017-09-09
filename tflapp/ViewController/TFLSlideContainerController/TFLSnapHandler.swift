import UIKit

typealias TFLSnapHandlerUpdateBlock = (_ pangestureView : UIView,_ velocity : CGFloat, _ newOrigin : CGPoint, _ final : Bool) -> ()

class TFLSnapHandler: NSObject {
    var panGestureView : UIView
    var panGestureStartY : CGFloat = 0
    let snapPositions : [CGFloat]
    var gestureRecognizer : UIPanGestureRecognizer?
    var snapHandlerUpdateBlock : TFLSnapHandlerUpdateBlock
    var containerView : UIView
    init(with panGestureView: UIView,in containerView: UIView, and snapPositions: [CGFloat], using snapHandlerUpdateBlock: @escaping TFLSnapHandlerUpdateBlock ) {
        self.panGestureView = panGestureView
        self.containerView = containerView
        self.snapHandlerUpdateBlock = snapHandlerUpdateBlock
        self.snapPositions  = snapPositions
        super.init()
        self.gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureHandler(_:)))
        panGestureView.addGestureRecognizer(self.gestureRecognizer!)
    }
    
    @objc func panGestureHandler(_ recognizer : UIPanGestureRecognizer) {
        let velocity = recognizer.velocity(in: self.containerView)
        let p = recognizer.location(in: self.containerView)
        let pGestureView = recognizer.location(in: self.panGestureView)
        switch recognizer.state {
        case .began:
            self.panGestureStartY = pGestureView.y
        case .changed:
            let origin = CGPoint(x:panGestureView.frame.origin.x,y:p.y - self.panGestureStartY )
            self.snapHandlerUpdateBlock(self.panGestureView, velocity.y,origin, false)
        case .ended:
            let originY = closestSnapPositionY(with: containerView,for: p.y - self.panGestureStartY )
            let origin = CGPoint(x:panGestureView.frame.origin.x,y:originY ?? 0)
            self.snapHandlerUpdateBlock(self.panGestureView, velocity.y,origin, true)
        default:
            break
        }
    }
}

// MARK: Private

extension TFLSnapHandler {
    fileprivate func closestSnapPositionY(with view: UIView, for positionY : CGFloat) -> CGFloat? {
        let translatedSnapPositions = self.snapPositions.map { view.frame.size.height * $0 }

        let distances = translatedSnapPositions.map { ($0,fabs($0 - positionY)) }
        let sortedDistance = distances.sorted (by: { $0.1 < $1.1 })
        let positionY = sortedDistance.first?.0
        return positionY
    }
}
