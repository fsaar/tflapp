import UIKit

typealias TFLChangeSetCompare<T> = (_ lhs : T,_ rhs: T) -> (Bool)

protocol TFLChangeSetProtocol  {
    func evaluateLists<T: Hashable >(oldList : [T], newList : [T],sortedBy compare: @escaping TFLChangeSetCompare<T>) -> (inserted : [(element:T,index:Int)],deleted : [(element:T,index:Int)],updated : [(element:T,index:Int)], moved : [(element:T,oldIndex:Int,newIndex:Int)])
}


extension TFLChangeSetProtocol {
    func evaluateLists<T: Hashable>(oldList : [T], newList : [T],sortedBy compare: @escaping TFLChangeSetCompare<T>)  -> (inserted : [(element:T,index:Int)],deleted : [(element:T,index:Int)], updated : [(element:T,index:Int)],moved : [(element:T,oldIndex:Int,newIndex:Int)])
    {
        guard !oldList.isEmpty else {
            return (newList.enumerated().map { ($0.1,$0.0) },[],[],[])
        }
        guard !newList.isEmpty else {
            return ([],oldList.enumerated().map { ($0.1,$0.0) },[],[])
        }
        
        let sortedOldList = oldList.sorted(by: compare)
        let sortedNewList = newList.sorted(by: compare)
        let oldSet = Set(oldList)
        let newSet = Set(newList)
        
       
        let insertedSet = newSet.subtracting(oldSet)
        let unchangedSet = newSet.intersection(oldSet)
        let deletedSet = oldSet.subtracting(newSet)
        
        
        let insertedTypes = newList.filter { insertedSet.contains($0) }.map { $0 }
        let insertedIndices = insertedTypes.compactMap { sortedNewList.index(of:$0) }
        let inserted = zip(insertedTypes,insertedIndices).map { $0 }
        
        
        let deletedTypes = oldList.filter { deletedSet.contains($0) }.map { $0 }
        let deletedIndices = deletedTypes.compactMap { sortedOldList.index(of:$0) }
        let deleted = zip(deletedTypes,deletedIndices).map { $0 }
        
        let movedTypes = findMovedTypes(in: oldList,and: newList,inserted: inserted ,deleted: deleted,sortedBy: compare)
        let moved = movedTypes.compactMap { (el : T) -> (T,Int,Int)? in
            guard let oldIndex = sortedOldList.index(of: el), let newIndex = sortedNewList.index(of: el) else {
                return nil
            }
            return (el,Int(oldIndex),Int(newIndex))
        }
        
        let updatedTypes = Array(unchangedSet.subtracting(Set(movedTypes)))
        let updated : [(T,Int)] = updatedTypes.compactMap { el in
            guard let index = sortedNewList.index(of:el) else  {
                return nil
            }
            return  (el,index)
        }
        
        return (inserted,deleted,updated,moved)
    }
    
}

fileprivate extension TFLChangeSetProtocol {
    
    func findMovedTypes<T: Hashable>(in oldList : [T],
                                     and newList : [T],
                                     inserted : [(element:T,index:Int)],
                                     deleted : [(element:T,index:Int)],
                                     sortedBy compare: @escaping TFLChangeSetCompare<T>) -> [T] {
        
        func innerFindMoveTypes(list : [T],movedTypes : [T] = []) -> [T] {
            guard list.count > 1 else {
                return movedTypes
            }
            // index is alwyays < list.count - 1. Why Check?
            for (index,el1) in list.enumerated() where index < list.count-1 {
                let el2 = list[index+1] // This should crash. Why doesn't it??
                if !compare(el1,el2) {
                    let lhsList = list.filter { $0 != el1 }
                    let rhsList = list.filter { $0 != el2 }
                    let lhsMovedTypes = innerFindMoveTypes(list: lhsList, movedTypes: movedTypes + [el1])
                    let rhsMovedTypes = innerFindMoveTypes(list: rhsList, movedTypes: movedTypes + [el2])
                    let newMovedTypes = lhsMovedTypes.count <= rhsMovedTypes.count ? lhsMovedTypes : rhsMovedTypes
                    return newMovedTypes
                }
            }
            return movedTypes
            
        }
        // Reconstruct the newList: newList = oldList - deletedItems + InsertedItems & updatedItems
        // 1. delete items from old list
        
        let deletedTypes = deleted.map { $0.element }
        let reducedOldList = oldList.filter { !deletedTypes.contains($0) }
        var updatedList = reducedOldList.compactMap { (el: T) -> (T?) in
            guard let index = newList.index(of: el) else {
                return nil
            }
            return newList[index]
        }
        // updatedList contains list of updated items. If there are no updated items. inserted
        
        // insert new elements into updated,
        // condition to only insert items and fall into updatedList's range. Correct?
        // to determined moved Items I can ignore new items that have been added after the last moved elements
        inserted.forEach { (arg) in
            // updated list is gonna grow here every time I insert something
            // inserted items need to be sorted by index before adding them into updated list
            let (element, index) = arg
            if 0..<updatedList.count ~= index {
                updatedList.insert(element, at: index)
            }
        }
        let movedTypes = innerFindMoveTypes(list: updatedList)
        return movedTypes
    }
    
}

extension UICollectionView : TFLChangeSetProtocol {}
