import UIKit

enum TFLCollectionFlowLayoutAppearingItemAnimationType {
    case scale
    case translate
}

class TFLCollectionFlowLayout : UICollectionViewFlowLayout {

    var deleteIndexPaths : [IndexPath] = []
    var insertIndexPaths : [IndexPath] = []
    lazy var scaleTransform : CGAffineTransform = CGAffineTransform.identity.scaledBy(x: 0.1, y: 0.1)

    override func finalizeCollectionViewUpdates() {
        self.deleteIndexPaths = []
        self.insertIndexPaths = []
    }
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)
        self.deleteIndexPaths = updateItems.filter{ $0.updateAction == .delete }.compactMap{ $0.indexPathBeforeUpdate }.sorted{ $0.item < $1.item }
        self.insertIndexPaths = updateItems.filter{ $0.updateAction == .insert }.compactMap{ $0.indexPathAfterUpdate }.sorted{ $0.item < $1.item }

    }


    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let layoutAttributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)

        if self.insertIndexPaths.contains(itemIndexPath), let width = self.collectionView?.frame.size.width {
            let animationType = appearingAnimationType(forItemAppearingAt: itemIndexPath)
            switch animationType {
            case .translate:
                layoutAttributes?.frame.origin.x += width
            case .scale:
                layoutAttributes?.transform = self.scaleTransform
            }
        }
        return layoutAttributes
    }

    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let layoutAttributes = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)
        if self.deleteIndexPaths.contains(itemIndexPath) {
            layoutAttributes?.transform = self.scaleTransform
        }
        return layoutAttributes
    }

}

// MARK: Private

private extension TFLCollectionFlowLayout {
    
    func appearingAnimationType(forItemAppearingAt indexPath: IndexPath) -> (TFLCollectionFlowLayoutAppearingItemAnimationType) {
        guard let startIndex = self.insertIndexPaths.firstIndex(of: indexPath),let itemCount = self.collectionView?.numberOfItems(inSection: 0),self.insertIndexPaths.count != itemCount else {
            return .scale
        }
        let indices = Array(indexPath.item..<itemCount)
        let insertedIndices = self.insertIndexPaths[startIndex..<self.insertIndexPaths.count].map{ $0.item }
        let subtractedSet = Set(indices).subtracting(insertedIndices)
        let animationType : TFLCollectionFlowLayoutAppearingItemAnimationType = subtractedSet.isEmpty ? .translate : .scale
        return animationType
    }
}
