import UIKit

protocol TFLChangeSetProtocol  {
    func evaluateLists<T: Equatable & Hashable >(oldList : [T], newList : [T], compare: @escaping (_ lhs : T,_ rhs: T) -> (Bool)) -> (inserted : [(element:T,index:Int)],deleted : [(element:T,index:Int)],updated : [(element:T,index:Int)], moved : [(element:T,oldIndex:Int,newIndex:Int)])
}


extension TFLChangeSetProtocol {
    func evaluateLists<T: Hashable>(oldList : [T], newList : [T], compare: @escaping (_ lhs : T,_ rhs: T) -> (Bool))  -> (inserted : [(element:T,index:Int)],deleted : [(element:T,index:Int)], updated : [(element:T,index:Int)],moved : [(element:T,oldIndex:Int,newIndex:Int)])
    {
        guard !oldList.isEmpty else {
            return (newList.enumerated().map { ($1,$0) },[],[],[])
        }
        guard !newList.isEmpty else {
            return ([],oldList.enumerated().map { ($1,$0) },[],[])
        }
        
        let sortedOldList = oldList.sorted(by: compare)
        let sortedNewList = newList.sorted(by: compare)
        let oldSet = Set(oldList)
        let newSet = Set(newList)
        
        func findMovedTypes(inserted : [(element:T,index:Int)],deleted : [(element:T,index:Int)]) -> [T] {
            
            func innerFindMoveTypes(list : [T],movedTypes : [T] = []) -> [T] {
                guard list.count > 1 else {
                    return movedTypes
                }
                
                for (index,el1) in list.enumerated() where index < list.count-1 {
                    let el2 = list[index+1]
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
            let deletedTypes = deleted.map { $0.element }
            let reducedOldList = oldList.filter { !deletedTypes.contains($0) }
            var updatedList = reducedOldList.flatMap { (el: T) -> (T?) in
                guard let index = newList.index(of: el) else {
                    return nil
                }
                return newList[index]
            }
            inserted.forEach { element,index in
                updatedList.insert(element, at: index)
            }
            let movedTypes = innerFindMoveTypes(list: updatedList)
            return movedTypes
        }
        
        
        let insertedSet = newSet.subtracting(oldSet)
        let unchangedSet = newSet.intersection(oldSet)
        let deletedSet = oldSet.subtracting(newSet)
        
        
        let insertedTypes = newList.filter { insertedSet.contains($0) }.map { $0 }
        let insertedIndices = insertedTypes.flatMap { sortedNewList.index(of:$0) }
        let inserted = zip(insertedTypes,insertedIndices).map { ($0,$1) }
        
        
        let deletedTypes = oldList.filter { deletedSet.contains($0) }.map { $0 }
        let deletedIndices = deletedTypes.flatMap { sortedOldList.index(of:$0) }
        let deleted = zip(deletedTypes,deletedIndices).map { ($0,$1) }
        
        let movedTypes = findMovedTypes(inserted: inserted ,deleted: deleted)
        let moved = movedTypes.flatMap { (el : T) -> (T,Int,Int)? in
            guard let oldIndex = sortedOldList.index(of: el), let newIndex = sortedNewList.index(of: el) else {
                return nil
            }
            return (el,Int(oldIndex),Int(newIndex))
        }
        
        let updatedTypes = Array(unchangedSet.subtracting(Set(movedTypes)))
        let updated : [(T,Int)] = updatedTypes.flatMap { el in
            guard let index = sortedNewList.index(of:el) else  {
                return nil
            }
            return  (el,index)
        }
        
        return (inserted,deleted,updated,moved)
    }
    
}

extension UICollectionView : TFLChangeSetProtocol {}
