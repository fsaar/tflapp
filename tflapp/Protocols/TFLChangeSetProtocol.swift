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
        
        
        let inserted : [(T,Int)] = insertedSet.compactMap { el in
            guard let index = sortedNewList.index(of:el) else {
                return nil
            }
            return (el,index)
        }

        let deleted : [(T,Int)] = deletedSet.compactMap { el in
            guard let index = sortedOldList.index(of:el) else {
                return nil
            }
            return (el,index)
        }
        
        
        let movedTypes = findMovedElements(in: oldList,and: newList,inserted: inserted ,deleted: deleted,sortedBy: compare)
        let moved : [(T,Int,Int)] = movedTypes.compactMap { el in
            guard let oldIndex = sortedOldList.index(of: el), let newIndex = sortedNewList.index(of: el) else {
                return nil
            }
            return (el,oldIndex,newIndex)
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
    
    func findMovedElements<T: Hashable>(in oldList : [T],
                                     and newList : [T],
                                     inserted : [(element:T,index:Int)],
                                     deleted : [(element:T,index:Int)],
                                     sortedBy compare: @escaping TFLChangeSetCompare<T>) -> [T] {
        
        func identifyMovedElementsFrom(unorderedList : [T],movedTypes : [T] = []) -> [T] {
            guard unorderedList.count > 1 else {
                return movedTypes
            }
            let tuples = zip(unorderedList,unorderedList.dropFirst())
            for (el1,el2) in tuples {
                if !compare(el1,el2) {
                    let lhsList = unorderedList.filter { $0 != el1 }
                    let rhsList = unorderedList.filter { $0 != el2 }
                    let lhsMovedTypes = identifyMovedElementsFrom(unorderedList: lhsList, movedTypes: movedTypes + [el1])
                    let rhsMovedTypes = identifyMovedElementsFrom(unorderedList: rhsList, movedTypes: movedTypes + [el2])
                    let newMovedTypes = lhsMovedTypes.count <= rhsMovedTypes.count ? lhsMovedTypes : rhsMovedTypes
                    return newMovedTypes
                }
            }
            return movedTypes
            
        }
        // Reconstruct the unordered newList
        // 1. delete items from old list
        // 2. insert new items
        
        let deletedTypes = deleted.map { $0.element }
        let reducedOldList = oldList.filter { !deletedTypes.contains($0) }
        var updatedList : [T] = reducedOldList.compactMap { el in
            guard let index = newList.index(of: el) else {
                return nil
            }
            return newList[index]
        }
       
        let sortedInsertedByIndex = inserted.sorted { $0.1 < $1.1 }
        sortedInsertedByIndex.forEach { (arg) in
            let (element, index) = arg
            updatedList.insert(element, at: index)
        }
        let movedTypes = identifyMovedElementsFrom(unorderedList: updatedList)
        return movedTypes
    }
    
}

extension UICollectionView : TFLChangeSetProtocol {}
