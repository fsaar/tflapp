
import UIKit
import Foundation

protocol Transitionable : TFLChangeSetProtocol {
    func transition<T : Equatable & Hashable>(from oldArrivalInfo: [T], to newArrivalInfo: [T],with compare: @escaping (_ lhs : T,_ rhs: T) -> (Bool), using updateBlock: ([IndexPath]) -> ())
}


extension UITableView : Transitionable {
    func transition<T : Equatable & Hashable>(from oldArrivalInfo: [T], to newArrivalInfo: [T],with compare: @escaping (_ lhs : T,_ rhs: T) -> (Bool), using updateBlock: ([IndexPath]) -> ()) {
        
        let (inserted ,deleted ,updated, moved) = self.evaluateLists(oldList: oldArrivalInfo, newList: newArrivalInfo, compare : compare)
        
        self.beginUpdates()
        let insertedIndexPaths = inserted.map { IndexPath(row: $0.index,section:0)}
        self.insertRows(at: insertedIndexPaths , with: .automatic)
        moved.forEach { self.moveRow(at: IndexPath(row: $0.oldIndex,section:0), to:  IndexPath(row: $0.newIndex,section:0)) }
        let deledtedIndexPaths = deleted.map { IndexPath(row: $0.index,section:0)}
        self.deleteRows(at: deledtedIndexPaths , with: .automatic)
        self.endUpdates()
        
        self.beginUpdates()
        let updatedIndexPaths = updated.map { IndexPath(row: $0.index,section:0)}
        let movedIndexPaths = moved.map { IndexPath(row: $0.newIndex,section:0)}
        updateBlock(updatedIndexPaths+movedIndexPaths)
        self.endUpdates()
    }
    
}
