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
    
    public var predictions : [TFLBusStopArrivalsViewModel.LinePredictionViewModel] = [] {
        didSet {
            self.reloadData()
        }
    }

}

extension TFLBusPredictionView : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = min(self.maxVisibleCells,self.predictions.count)
        return count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: TFLBusPredictionViewCell.self), for: indexPath)
        
        if let busPredictionCell = cell as? TFLBusPredictionViewCell {
            let prediction = predictions[indexPath.row]
            busPredictionCell.configure(with: prediction)
        }
        return cell
    }

}
