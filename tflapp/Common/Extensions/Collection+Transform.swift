import UIKit

typealias TFLTransformCollectionCompare<T> = (_ lhs : T,_ rhs: T) -> (Bool)

fileprivate typealias Offset = Int

fileprivate enum Action {
    case inserted
    case removed
    case moved
    
}

extension BidirectionalCollection where Element : Hashable {
  
    
    func transformTo(newList : [Element],sortedBy compare: @escaping TFLTransformCollectionCompare<Element>)  -> (inserted : [(element:Element,index:Int)],deleted : [(element:Element,index:Int)], updated : [(element:Element,index:Int)],moved : [(element:Element,oldIndex:Int,newIndex:Int)])
    {
        let sortedOldList = self.sorted(by: compare)
        let sortedNewList = newList.sorted(by: compare)
        return sortedOldList.transformTo(newList: sortedNewList)
    }
    
    func transformTo(newList : [Element])  -> (inserted : [(element:Element,index:Int)],deleted : [(element:Element,index:Int)], updated : [(element:Element,index:Int)],moved : [(element:Element,oldIndex:Int,newIndex:Int)])
    {
        
        guard newList.count == Set(newList).count else {
            return ([],[],[],[])
        }
        guard !self.isEmpty else {
            return (newList.enumerated().map { ($0.1,$0.0) },[],[],[])
        }
        guard !newList.isEmpty else {
            return ([],self.enumerated().map { ($0.1,$0.0) },[],[])
        }
        
        let diff = newList.difference(from:self).inferringMoves()
        let translatedDiff : [(action:Action,element:Element,offset1:Offset,offset2:Offset?)] = diff.map { d in
            switch d {
            case let .insert(offset: offset, element: element, associatedWith: association):
                return (.inserted,element,offset,association)
            case let .remove(offset: offset, element: element, associatedWith: association):
                return (.removed,element,offset,association)
            }
        }
        let moved : [(element:Element,oldIndex:Int,newIndex:Int)] = translatedDiff.compactMap { action,element,newIndex,oldIndex in
                                                                                                guard action == .inserted,let oldIndex = oldIndex else {
                                                                                                    return nil
                                                                                                }
                                                                                                return (element,oldIndex,newIndex)
        }
        let inserted = translatedDiff.filter { $0.offset2 == nil }.filter { $0.action == .inserted }.map { (element:$0.element,index:$0.offset1) }
        let deleted = translatedDiff.filter { $0.offset2 == nil }.filter { $0.action == .removed }.map { (element:$0.element,index:$0.offset1) }
        let changedElements = Set(translatedDiff.map { $0.element })
        let updated : [(Element,Int)] = newList.enumerated().filter { !changedElements.contains($0.1) }.map { ($0.1,$0.0) }
        
        return (inserted,deleted,updated,moved)
        
    }
}
