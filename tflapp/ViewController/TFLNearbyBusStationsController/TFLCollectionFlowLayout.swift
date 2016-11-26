import UIKit

class TFLCollectionFlowLayout : UICollectionViewFlowLayout {
    
    var deleteIndexPaths : [IndexPath] = []
    var insertIndexPaths : [IndexPath] = []
    
    override func finalizeCollectionViewUpdates() {
        self.deleteIndexPaths = []
        self.insertIndexPaths = []
    }
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)
        self.deleteIndexPaths = updateItems.filter { $0.updateAction == .delete }.flatMap { $0.indexPathBeforeUpdate }
        self.self.insertIndexPaths = updateItems.filter { $0.updateAction == .insert }.flatMap { $0.indexPathAfterUpdate }
    }
    
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let layoutAttributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
        
        if self.insertIndexPaths.contains(itemIndexPath), let width = self.collectionView?.frame.size.width {
            layoutAttributes?.frame.origin.x += width
        }
        return layoutAttributes
    }
    
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let layoutAttributes = super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)
        if self.deleteIndexPaths.contains(itemIndexPath), let width = self.collectionView?.frame.size.width {
            layoutAttributes?.frame.origin.x -= width
        }
        return layoutAttributes
    }

}
