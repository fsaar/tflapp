import UIKit

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
            
            let oldPredictions = self.predictions
            
            let (inserted ,deleted ,updated, moved) = self.evaluateLists(oldList: oldPredictions, newList: newPredictions, compare : TFLBusStopArrivalsViewModel.LinePredictionViewModel.compare)
            self.performBatchUpdates({
                self.predictions = newPredictions
                let insertedIndexPaths = inserted.map { IndexPath(item: $0.index,section:0)}
                self.insertItems(at: insertedIndexPaths )
                moved.forEach { self.moveItem(at: IndexPath(item: $0.oldIndex,section:0), to:  IndexPath(item: $0.newIndex,section:0)) }
                let deletedIndexPaths = deleted.map { IndexPath(item: $0.index,section:0)}
                self.deleteItems(at: deletedIndexPaths)
            }) { _ in
                let updatedIndexPaths = updated.map { IndexPath(item: $0.index,section:0)}
                let movedIndexPaths = moved.map { IndexPath(item: $0.newIndex,section:0)}
                (movedIndexPaths+updatedIndexPaths).forEach { indexPath in
                    let cell = self.cellForItem(at: indexPath)
                    self.configure(cell, at: indexPath)
                }
            }

            
//            self.transition(from: oldPredictions, to: predictions, with: TFLBusStopArrivalsViewModel.LinePredictionViewModel.compare) { [weak self] updatedIndexPaths in
//                updatedIndexPaths.forEach { indexPath in
//                    let cell = self?.cellForItem(at: indexPath)
//                    self?.configure(cell, at: indexPath)
//                }
//            }
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
