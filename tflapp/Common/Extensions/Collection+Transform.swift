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
            
          //  let movedTypes =
            let moved : [(Element,Int,Int)] = try findMovedElements(in: newList,inserted: inserted ,deleted: deleted,sortedBy: compare)
            let movedTypes = moved.map { $0.0 }
            
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
    
    func findMovedElements(in newList : [Element],
                                     inserted : [(element:Element,index:Int)],
                                     deleted : [(element:Element,index:Int)],
                                     sortedBy compare: @escaping TFLTransformCollectionCompare<Element>) throws -> [(Element,Int,Int)]  {


        // Reconstruct the unordered newList
        // 1. delete items from old list
        // 2. insert new items
        
        let deletedTypes = deleted.map { $0.element }
        let reducedOldList = self.filter { !deletedTypes.contains($0) }
        let updatedList : [Element] = try reducedOldList.compactMap { el in
            guard let index = newList.index(of: el) else {
                throw CollectionError.findMovedElementsIndexOutOfRange
            }
            return newList[index]
        }
        let unsortedNewList = try updatedList.mergeELements(with: inserted)
        let movedTypes : [(Element,Int,Int)] = updatedList.compactMap { element in
            guard let index = unsortedNewList.index(of:element),let index2 = newList.index(of:element),index != index2 else {
                return nil
            }
            return (element,index,index2)
        }.sorted { $0.2 < $1.2 }
        
        var transfomedList = unsortedNewList
        var reducedMovedTypes : [(Element,Int,Int)] = []
        for (element,from,to) in movedTypes     {
            reducedMovedTypes += [(element,from,to)]
            transfomedList = transfomedList.filter { $0 != element }
            transfomedList.insert(element, at: to)
            if transfomedList == newList {
                break
            }
        }
        return reducedMovedTypes
    }

}
