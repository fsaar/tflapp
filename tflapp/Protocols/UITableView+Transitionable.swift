import UIKit
import Foundation

protocol Transitionable  {
    func transition<T : Hashable>(from oldArrivalInfo: [T], to newArrivalInfo: [T],with compare: @escaping (_ lhs : T,_ rhs: T) -> (Bool), using updateBlock: @escaping  ([IndexPath]) -> ())
}
extension Collection where Element == Int  {
    func indexPaths(_ section : Int = 0) -> [IndexPath] {
        return self.map { IndexPath(item: $0, section: section) }
    }
}

extension UITableView : Transitionable {
    func transition<T : Hashable>(from oldArrivalInfo: [T], to newArrivalInfo: [T],with compare: @escaping (_ lhs : T,_ rhs: T) -> (Bool), using updateBlock: @escaping  ([IndexPath]) -> ()) {

        DispatchQueue.global().async {
            let (inserted ,deleted ,updated, moved) = oldArrivalInfo.transformTo(newList: newArrivalInfo, sortedBy : compare)
            DispatchQueue.main.async {
                self.performBatchUpdates({
                    let deletedIndexPaths = deleted.map { $0.index }.indexPaths().sorted(by:>)
                    self.deleteRows(at: deletedIndexPaths , with: .automatic)
                    let insertedIndexPaths = inserted.map { $0.index }.indexPaths().sorted(by:<)
                    self.insertRows(at: insertedIndexPaths , with: .automatic)
                    moved.forEach { self.moveRow(at: IndexPath(row: $0.oldIndex,section:0), to:  IndexPath(row: $0.newIndex,section:0)) }
                }, completion: { _ in
                    let updatedIndexPaths = updated.map { $0.index }.indexPaths()
                    let movedIndexPaths = moved.map { $0.newIndex }.indexPaths()
                    updateBlock(updatedIndexPaths+movedIndexPaths)
                })
            }
        }
        

    }

}
