import UIKit
import CoreData

extension MutableCollection where Index == Int, Iterator.Element == TFLBusStopArrivalsViewModel.LinePredictionViewModel {
    subscript(indexPath : IndexPath) -> TFLBusStopArrivalsViewModel.LinePredictionViewModel {
        get {
            return self[indexPath.row]
        }
        set {
           self[indexPath.row] = newValue
        }
    }
}

protocol TFLBusPredictionViewDelegate : AnyObject {
    func busPredictionView(_ busPredictionView: TFLBusPredictionView,didSelectLine line: String,with vehicleID: String,at station : String)
    func busPredictionView(_ busPredictionView: TFLBusPredictionView,showReminderFor line: String,with vehicleID: String,at station : String,arrivingIn seconds : Int)
}

class TFLBusPredictionView: UICollectionView {
    weak var busPredictionViewDelegate : TFLBusPredictionViewDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.delegate = self
        
        diffableDataSource = UICollectionViewDiffableDataSource(collectionView: self) { collectionView,indexPath,prediction in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: TFLBusPredictionViewCell.self), for: indexPath) as? TFLBusPredictionViewCell
            cell?.configure(with: prediction,as : false) { [weak self] in
                self?.showReminderHandlerForPrediction(prediction)
            }
            return cell
        }
    }

    fileprivate var diffableDataSource : UICollectionViewDiffableDataSource<String,TFLBusStopArrivalsViewModel.LinePredictionViewModel>?
    fileprivate let sectionIdentifier = "TFLBusPredictionViewSectionIdentifier"
    func setPredictions( predictions : [TFLBusStopArrivalsViewModel.LinePredictionViewModel], animated: Bool = false) {
        
        let animatingDifference = animated && !self.predictions.isEmpty
        let (_ ,_ ,updated, moved) = self.predictions.transformTo(newList:predictions, sortedBy:TFLBusStopArrivalsViewModel.LinePredictionViewModel.compare)
        self.predictions = predictions
        
        var snapshot = NSDiffableDataSourceSnapshot<String, TFLBusStopArrivalsViewModel.LinePredictionViewModel>()
        snapshot.appendSections([sectionIdentifier])
  
        snapshot.appendItems(predictions)
        diffableDataSource?.apply(snapshot,animatingDifferences: animatingDifference)
        
        let updatedIndexPaths = updated.map { IndexPath(item: $0.index,section:0) }
        let movedIndexPaths = moved.map { IndexPath(item: $0.newIndex,section:0) }
        (updatedIndexPaths+movedIndexPaths).forEach { indexPath in
            
            if let busPredictionCell = self.cellForItem(at: indexPath) as? TFLBusPredictionViewCell {
                let prediction = predictions[indexPath]
                busPredictionCell.configure(with: prediction,as : true) { [weak self] in
                    self?.showReminderHandlerForPrediction(prediction)
                }
            }
        }
    }
    public var predictions : [TFLBusStopArrivalsViewModel.LinePredictionViewModel] = []
}

// MARK: - UICollectionViewDelegate

extension TFLBusPredictionView : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let prediction = predictions[indexPath]
        self.busPredictionViewDelegate?.busPredictionView(self, didSelectLine: prediction.line,with:prediction.vehicleID,at:prediction.busStopIdentifier)
    }
}

fileprivate extension TFLBusPredictionView {
    func showReminderHandlerForPrediction(_ prediction : TFLBusStopArrivalsViewModel.LinePredictionViewModel) {
        self.busPredictionViewDelegate?.busPredictionView(self, showReminderFor: prediction.line, with: prediction.vehicleID, at: prediction.busStopIdentifier, arrivingIn: prediction.timeToStation)
    }
}
