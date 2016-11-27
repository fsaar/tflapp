import UIKit
import Crashlytics

class TFLBusPredictionView: UICollectionView {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.dataSource = self
    }
    
    var maxVisibleCells : Int {
        guard let flowLayout = self.collectionViewLayout as? UICollectionViewFlowLayout else {
            return Int.max
        }
        let availableWith = self.frame.size.width
        let distance = flowLayout.minimumLineSpacing
        let maxVisisbleCells = Int((availableWith+distance) / (flowLayout.itemSize.width+distance))
        return maxVisisbleCells
    }
    
    func setPredictions( predictions : [TFLBusStopArrivalsViewModel.LinePredictionViewModel], animated: Bool = false) {
        let newPredictions = Array(predictions[0..<min(predictions.count,self.maxVisibleCells)])
        if  !animated || self.predictions.isEmpty {
            self.predictions = newPredictions
            self.reloadData()
        }
        else {
            Crashlytics.log("oldTuples:\(self.predictions.map { $0.identifier }.joined(separator: ","))\nnewTuples:\(predictions.map { $0.identifier }.joined(separator: ","))")

            self.transition(from: self.predictions, to: predictions,
                            with: TFLBusStopArrivalsViewModel.LinePredictionViewModel.compare,
                            using: { [weak self] animationBlock in
                                        self?.performBatchUpdates({
                                            self?.predictions = newPredictions
                                            animationBlock()
                                            }, completion: nil)
                                    }
                            , with: { [weak self] updateIndexPaths in
                                        updateIndexPaths.forEach { indexPath in
                                            let cell = self?.cellForItem(at: indexPath)
                                            self?.configure(cell, at: indexPath)
                                        }
            })
        }
    }
    public var predictions : [TFLBusStopArrivalsViewModel.LinePredictionViewModel] = [] 
}

// MARK: UICollectionViewDataSource

extension TFLBusPredictionView : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = self.predictions.count
        return count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: TFLBusPredictionViewCell.self), for: indexPath)
        configure(cell, at: indexPath)
        return cell
    }

}

// MARK: Helper

fileprivate extension TFLBusPredictionView {
    func configure(_ cell: UICollectionViewCell?,at indexPath : IndexPath) {
        if let busPredictionCell = cell as? TFLBusPredictionViewCell {
            let prediction = predictions[indexPath.row]
            busPredictionCell.configure(with: prediction)
        }
    }
}
