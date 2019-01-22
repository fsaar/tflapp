import UIKit

typealias TFLTransformCollectionCompare<T> = (_ lhs : T,_ rhs: T) -> (Bool)

enum SetIndexListError : Error {
    case elementNotInTargetList
}

enum CollectionError : Error {
    case mergeIndexOutOfRange
    case findMovedElementsIndexOutOfRange
}

//enum Collection

extension Collection where Element : Hashable {
    func transformTo(newList : [Element],sortedBy compare: @escaping TFLTransformCollectionCompare<Element>)  -> (inserted : [(element:Element,index:Int)],deleted : [(element:Element,index:Int)], updated : [(element:Element,index:Int)],moved : [(element:Element,oldIndex:Int,newIndex:Int)])
    {
        guard !self.isEmpty else {
            return (newList.enumerated().map { ($0.1,$0.0) },[],[],[])
        }
        guard !newList.isEmpty else {
            return ([],self.enumerated().map { ($0.1,$0.0) },[],[])
        }

        let sortedOldList = self.sorted(by: compare)
        let sortedNewList = newList.sorted(by: compare)
        let oldSet = Set(self)
        let newSet = Set(newList)


        let insertedSet = newSet.subtracting(oldSet)
        let unchangedSet = newSet.intersection(oldSet)
        let deletedSet = oldSet.subtracting(newSet)

        do {
            let inserted = try insertedSet.indexedList(basedOn: sortedNewList)
            
            let deleted = try deletedSet.indexedList(basedOn: sortedOldList)
            
            let movedTypes = try findMovedElements(in: newList,inserted: inserted ,deleted: deleted,sortedBy: compare)
            let moved : [(Element,Int,Int)] = movedTypes.compactMap { el in
                guard let oldIndex = sortedOldList.index(of: el), let newIndex = sortedNewList.index(of: el) else {
                    return nil
                }
                return (el,oldIndex,newIndex)
            }
            
            let updatedTypes = unchangedSet.subtracting(Set(movedTypes))
            let updated = try updatedTypes.indexedList(basedOn: sortedNewList)
            return (inserted,deleted,updated,moved)
        }
        catch {
            return (newList.enumerated().map { ($0.1,$0.0) },self.enumerated().map { ($0.1,$0.0) },[],[])
        }
    }

    func mergeELements(with indexedList : [(element:Element,index:Int)]) throws  -> [Element] {
        let sortedIndexListByIndex = indexedList.sorted { $0.1 < $1.1 }
        var copy = Array(self)
        try sortedIndexListByIndex.forEach { arg in
            let (element, index) = arg
            guard index <= copy.count else {
                throw CollectionError.mergeIndexOutOfRange
            }
            copy.insert(element, at: index)
        }
        return copy
        
    }
}


fileprivate extension Set {
    func indexedList(basedOn list:[Element]) throws -> [(Element,Int)] {
        let indexList : [(Element,Int)] = try self.compactMap { el in
            guard let index = list.index(of:el) else {
                throw SetIndexListError.elementNotInTargetList
            }
            return (el,index)
        }
        return indexList
    }
}

fileprivate extension Collection where Element : Hashable{
    func identifyMovedElementsFrom(unorderedList : [Element],movedTypes : [Element] = [],sortedBy compare: @escaping TFLTransformCollectionCompare<Element> ) -> [Element] {
        guard unorderedList.count > 1 else {
            return movedTypes
        }
        let unorderedTuple : (Element,Element)? = zip(unorderedList,unorderedList.dropFirst()).lazy.first { !compare($0.0,$0.1) }
        guard let (el1,el2) = unorderedTuple else {
            return movedTypes
        }
        let lhsList = unorderedList.filter { $0 != el1 }
        let rhsList = unorderedList.filter { $0 != el2 }
        let lhsMovedTypes = identifyMovedElementsFrom(unorderedList: lhsList, movedTypes: movedTypes + [el1],sortedBy: compare)
        let rhsMovedTypes = identifyMovedElementsFrom(unorderedList: rhsList, movedTypes: movedTypes + [el2],sortedBy: compare)
        let newMovedTypes = lhsMovedTypes.count <= rhsMovedTypes.count ? lhsMovedTypes : rhsMovedTypes
        return newMovedTypes
    }
    
    

    func findMovedElements(in newList : [Element],
                                     inserted : [(element:Element,index:Int)],
                                     deleted : [(element:Element,index:Int)],
                                     sortedBy compare: @escaping TFLTransformCollectionCompare<Element>) throws -> [Element] {


        // Reconstruct the unordered newList
        // 1. delete items from old list
        // 2. insert new items
        
        let deletedTypes = deleted.map { $0.element }
        let reducedOldList = self.filter { !deletedTypes.contains($0) }
        let sortedInsertedByIndex = inserted.sorted { $0.1 < $1.1 }
        let updatedList : [Element] = try reducedOldList.compactMap { el in
            guard let index = newList.index(of: el) else {
                throw CollectionError.findMovedElementsIndexOutOfRange
            }
            return newList[index]
        }.mergeELements(with: sortedInsertedByIndex)

        let movedTypes = identifyMovedElementsFrom(unorderedList: updatedList,sortedBy: compare)
        return movedTypes
    }

}
