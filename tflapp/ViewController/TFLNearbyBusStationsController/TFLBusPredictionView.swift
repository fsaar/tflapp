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

protocol TFLBusPredictionViewDelegate : class {
    func busPredictionView(_ busPredictionView: TFLBusPredictionView,didSelectLine line: String)
}

class TFLBusPredictionView: UICollectionView {
    weak var busPredictionViewDelegate : TFLBusPredictionViewDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.dataSource = self
        self.delegate = self
    }

    func setPredictions( predictions : [TFLBusStopArrivalsViewModel.LinePredictionViewModel], animated: Bool = false) {
        if  !animated || self.predictions.isEmpty {
            self.predictions = predictions
            self.reloadData()
        }
        else {
            var (inserted ,deleted ,updated, moved) : (inserted : [(element:TFLBusStopArrivalsViewModel.LinePredictionViewModel,index:Int)],deleted : [(element:TFLBusStopArrivalsViewModel.LinePredictionViewModel,index:Int)], updated : [(element:TFLBusStopArrivalsViewModel.LinePredictionViewModel,index:Int)],moved : [(element:TFLBusStopArrivalsViewModel.LinePredictionViewModel,oldIndex:Int,newIndex:Int)]) = ([],[],[],[])

            DispatchQueue.global().async {
                (inserted ,deleted ,updated, moved) = self.predictions.transformTo(newList:predictions, sortedBy:TFLBusStopArrivalsViewModel.LinePredictionViewModel.compare)
                self.predictions = predictions
                DispatchQueue.main.async {
                    self.performBatchUpdates({ [weak self] in
                        let insertedIndexPaths = inserted.map { IndexPath(item: $0.index,section:0)}
                        self?.insertItems(at: insertedIndexPaths )
                        moved.forEach { self?.moveItem(at: IndexPath(item: $0.oldIndex,section:0), to:  IndexPath(item: $0.newIndex,section:0)) }
                        let deletedIndexPaths = deleted.map { IndexPath(item: $0.index,section:0)}
                        self?.deleteItems(at: deletedIndexPaths)
                        } ,completion: { [weak self]  _ in
                            self?.performBatchUpdates({ [weak self] in
                                
                                let updatedIndexPaths = updated.map { IndexPath(item: $0.index,section:0)}
                                let movedIndexPaths = moved.map { IndexPath(item: $0.newIndex,section:0)}
                                (updatedIndexPaths+movedIndexPaths).forEach { indexPath in
                                    let cell = self?.cellForItem(at: indexPath)
                                    self?.configure(cell, at: indexPath, as : true)
                                }
                                },completion: nil)
                    })
                    
                    
                }
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

// MARK: UICollectionViewDelegate

extension TFLBusPredictionView : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let prediction = predictions[indexPath]
        self.busPredictionViewDelegate?.busPredictionView(self, didSelectLine: prediction.line)
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
