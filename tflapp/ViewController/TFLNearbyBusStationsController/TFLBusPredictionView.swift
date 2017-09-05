import UIKit
import Crashlytics

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
        let visiblePredictions = Array(predictions[0..<min(predictions.count,self.maxVisibleCells)])
        if  !animated || self.predictions.isEmpty || self.predictions ==  visiblePredictions {
            self.predictions = visiblePredictions
            self.reloadData()
        }
        else {
            Crashlytics.log("oldTuples:\(self.predictions.map { $0.identifier }.joined(separator: ","))\nnewTuples:\(visiblePredictions.map { $0.identifier }.joined(separator: ","))")
            
            let (inserted ,deleted ,updated, moved) = self.evaluateLists(oldList: self.predictions, newList: visiblePredictions, compare : TFLBusStopArrivalsViewModel.LinePredictionViewModel.compare)
            if inserted.isEmpty && moved.isEmpty && deleted.isEmpty {
                self.reloadData()
            }
            else {
                self.performBatchUpdates({ [weak self] in
                    Crashlytics.notify()
                    self?.predictions = visiblePredictions
                    let insertedIndexPaths = inserted.map { IndexPath(item: $0.index,section:0)}
                    self?.insertItems(at: insertedIndexPaths )
                    moved.forEach { self?.moveItem(at: IndexPath(item: $0.oldIndex,section:0), to:  IndexPath(item: $0.newIndex,section:0)) }
                    let deletedIndexPaths = deleted.map { IndexPath(item: $0.index,section:0)}
                    self?.deleteItems(at: deletedIndexPaths)
                    } ,completion: { [weak self]  _ in
                        self?.performBatchUpdates({ [weak self] in
                            Crashlytics.notify()
                            let updatedIndexPaths = updated.map { IndexPath(item: $0.index,section:0)}
                            let movedIndexPaths = moved.map { IndexPath(item: $0.newIndex,section:0)}
                            (updatedIndexPaths+movedIndexPaths).forEach { indexPath in
                                let cell = self?.cellForItem(at: indexPath)
                                self?.configure(cell, at: indexPath, as : true)
                            }
                            },completion: { _ in
                                Crashlytics.notify()
                        })
                })
                
            }
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
    func configure(_ cell: UICollectionViewCell?,at indexPath : IndexPath,as update: Bool = false) {
        if let busPredictionCell = cell as? TFLBusPredictionViewCell {
            let prediction = predictions[indexPath]
            busPredictionCell.configure(with: prediction,as : update)
        }
    }
}
