
import UIKit
import Foundation

protocol Transitionable : TFLChangeSetProtocol {
    func transition<T : Equatable & Hashable>(from oldArrivalInfo: [T],
                    to newArrivalInfo: [T],
                    with compare: @escaping (_ lhs : T,_ rhs: T) -> (Bool),
                    using animationBlock: (_ block :@escaping  ()->()) -> (Void),
                    with updateBlock: @escaping ([IndexPath]) -> ())
}


extension UITableView : Transitionable {
    func transition<T : Equatable & Hashable>(  from oldArrivalInfo: [T],
                                                to newArrivalInfo: [T],
                                                with compare: @escaping (_ lhs : T,_ rhs: T) -> (Bool),
                                                using animationBlock: (_ block :@escaping  ()->()) -> (Void),
                                                with updateBlock:@escaping ([IndexPath]) -> ()) {
        
        let (inserted ,deleted ,updated, moved) = self.evaluateLists(oldList: oldArrivalInfo, newList: newArrivalInfo, compare : compare)
        
        animationBlock {
            let insertedIndexPaths = inserted.map { IndexPath(row: $0.index,section:0)}
            self.insertRows(at: insertedIndexPaths , with: .automatic)
            moved.forEach { self.moveRow(at: IndexPath(row: $0.oldIndex,section:0), to:  IndexPath(row: $0.newIndex,section:0)) }
            let deledtedIndexPaths = deleted.map { IndexPath(row: $0.index,section:0)}
            self.deleteRows(at: deledtedIndexPaths , with: .automatic)
        }
        
        let updatedIndexPaths = updated.map { IndexPath(row: $0.index,section:0)}
        let movedIndexPaths = moved.map { IndexPath(row: $0.newIndex,section:0)}
        updateBlock(updatedIndexPaths+movedIndexPaths)
    }
    
}


extension UICollectionView : TFLChangeSetProtocol {
    func transition<T : Equatable & Hashable>(from oldArrivalInfo: [T],
                                                to newArrivalInfo: [T],
                                                with compare: @escaping (_ lhs : T,_ rhs: T) -> (Bool),
                                                using animationBlock: (_ block :@escaping ()->()) -> (Void),
                                                with updateBlock: @escaping ([IndexPath]) -> ()) {
        
        let (inserted ,deleted ,updated, moved) = self.evaluateLists(oldList: oldArrivalInfo, newList: newArrivalInfo, compare : compare)
        animationBlock {
            let insertedIndexPaths = inserted.map { IndexPath(item: $0.index,section:0)}
            self.insertItems(at: insertedIndexPaths )
            moved.forEach { self.moveItem(at: IndexPath(item: $0.oldIndex,section:0), to:  IndexPath(item: $0.newIndex,section:0)) }
            let deletedIndexPaths = deleted.map { IndexPath(item: $0.index,section:0)}
            self.deleteItems(at: deletedIndexPaths)
        }
        let updatedIndexPaths = updated.map { IndexPath(item: $0.index,section:0)}
        let movedIndexPaths = moved.map { IndexPath(item: $0.newIndex,section:0)}
        updateBlock(updatedIndexPaths+movedIndexPaths)
    }
    
}
