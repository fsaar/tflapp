import Foundation
import Nimble
import UIKit
import Quick
import CoreData

@testable import London_Bus


fileprivate struct Pos : Hashable {
    let a : M
    let b : Int
    init(_ tuple:(a: M,b: Int)) {
        self.a = tuple.a
        self.b = tuple.b
    }
    init(_ a: M,_ b: Int) {
        self.a = a
        self.b = b
    }
    var hashValue: Int {
        return "\(a),\(b)".hashValue
    }
    
    static public func ==(lhs : Pos, rhs : Pos) -> Bool {
        return (lhs.a == rhs.a) && (rhs.b == lhs.b)
    }
}

fileprivate struct MovedPos : Hashable {
    let a : M
    let b : Int
    let c : Int
    init(_ tuple : (a: M,b: Int,c: Int)) {
        self.a = tuple.a
        self.b = tuple.b
        self.c = tuple.c
    }
    init(_ a: M,_ b: Int,_ c: Int) {
        self.a = a
        self.b = b
        self.c = c
    }
    var hashValue: Int {
        return "\(a),\(b),\(c)".hashValue
    }

    static public func ==(lhs : MovedPos, rhs : MovedPos) -> Bool {
        return (lhs.a == rhs.a) && (rhs.b == lhs.b) && (rhs.c == lhs.c)
    }
}


fileprivate struct M : Hashable {
    let id : String
    let x : Int
    public static func ==(lhs: M, rhs: M) -> Bool {
        return lhs.id == rhs.id
    }
    public static func compare(lhs: M, rhs: M) -> Bool {
        return lhs.x <= rhs.x
    }
    init(_ id: String,_ x: Int) {
        self.id = id
        self.x = x
    }
    
   // var debugDescription: String { return "[\(id)]\(x)" } //tempList
    var hashValue: Int  { return id.hashValue }
}

class TFLChangeSetProtocolSpecs : QuickSpec {
    
    override func spec() {
      
        beforeEach {
        
        }
        it("should return the correct tuple when nothing's been inserted : [] -> []") {
            let newList : [M] = []
            let (inserted ,deleted ,updated, moved)  = [].transformTo(newList: newList, sortedBy : M.compare)
            expect(Set(inserted.map { Pos($0) })) == Set([])
            expect(Set(deleted.map { Pos($0) })) == Set([])
            expect(Set(updated.map { Pos($0) })) == Set([])
            expect(Set(moved.map { MovedPos($0) })) == Set([])
            
        }
        
        it("should return the correct tuple when inserted 1,2,4,6,8 : [] -> [1,2,4,6,8]") {
            let newList = [1,2,4,6,8].map { M("\($0)",$0) }
            let (inserted ,deleted ,updated, moved)  = [].transformTo(newList: newList, sortedBy : M.compare)
            expect(Set(inserted.map { Pos($0) })) == Set([Pos(M("1",1),0),Pos(M("2",2),1),Pos(M("4",4),2),Pos(M("6",6),3),Pos(M("8",8),4)])
            expect(Set(deleted.map { Pos($0) })) == Set([])
            expect(Set(updated.map { Pos($0) })) == Set([])
            expect(Set(moved.map { MovedPos($0) })) == Set([])
        }
        
        it("should return the correct tuple when nothing's changed : [1,2,4,6,8] -> [1,2,4,6,8]") {
            let oldList = [1,2,4,6,8].map { M("\($0)",$0) }
            let newList = [1,2,4,6,8].map { M("\($0)",$0) }
            let (inserted ,deleted ,updated, moved)  = oldList.transformTo(newList: newList, sortedBy : M.compare)
            expect(Set(inserted.map { Pos($0) })) == Set([])
            expect(Set(deleted.map { Pos($0) })) == Set([])
            expect(Set(updated.map { Pos($0) })) == Set([Pos(M("1",1),0),Pos(M("2",2),1),Pos(M("4",4),2),Pos(M("6",6),3),Pos(M("8",8),4)])
            expect(Set(moved.map { MovedPos($0) })) == Set([])
            
        }

        it("should return the correct tuple when everything's removed : [1,2,4,6,8] -> []") {
            let oldList = [1,2,4,6,8].map { M("\($0)",$0) }
            let (inserted ,deleted ,updated, moved)  = oldList.transformTo(newList: [], sortedBy : M.compare)
            expect(Set(inserted.map { Pos($0) })) == Set([])
            expect(Set(deleted.map { Pos($0) })) == Set([Pos(M("1",1),0),Pos(M("2",2),1),Pos(M("4",4),2),Pos(M("6",6),3),Pos(M("8",8),4)])
            expect(Set(updated.map { Pos($0) })) == Set([])
            expect(Set(moved.map { MovedPos($0) })) == Set([])
            
        }

        it("should return the correct tuple when inserted 5 : ([1,2,4,6,8] -> [1,2,4,5,6,8]") {
            let oldList = [1,2,4,6,8].map { M("\($0)",$0) }
            let newList = [1,2,4,5,6,8].map { M("\($0)",$0) }
            let (inserted ,deleted ,updated, moved)  = oldList.transformTo( newList: newList, sortedBy : M.compare)
            expect(Set(inserted.map { Pos($0) })) == Set([Pos(M("5",5),3)])
            expect(Set(deleted.map { Pos($0) })) == Set([])
            expect(Set(updated.map { Pos($0) })) == Set([Pos(M("1",1),0),Pos(M("2",2),1),Pos(M("4",4),2),Pos(M("6",6),4),Pos(M("8",8),5)])
            expect(Set(moved.map { MovedPos($0) })) == Set([])
        }
        it("should return the correct tuple when deleted 2 : ([1,2,4,5,6,8] -> [1,4,5,6,8]") {
            let oldList = [1,2,4,5,6,8].map { M("\($0)",$0) }
            let newList = [1,4,5,6,8].map { M("\($0)",$0) }
            let (inserted ,deleted ,updated, moved)  = oldList.transformTo(newList: newList, sortedBy : M.compare)
            expect(Set(inserted.map { Pos($0) })) == Set([])
            expect(Set(deleted.map { Pos($0) })) == Set([Pos(M("2",2),1)])
            expect(Set(updated.map { Pos($0) })) == Set([Pos(M("1",1),0),Pos(M("4",4),1),Pos(M("5",5),2),Pos(M("6",6),3),Pos(M("8",8),4)])
            expect(Set(moved.map { MovedPos($0) })) == Set([])
        }
        it("should return the correct tuple when deleted 1,4 : ([1,4,5,6,8] -> [5,6,8]") {
            let oldList = [1,4,5,6,8].map { M("\($0)",$0) }
            let newList = [5,6,8].map { M("\($0)",$0) }
            let (inserted ,deleted ,updated, moved)  = oldList.transformTo(newList: newList, sortedBy : M.compare)
            expect(Set(inserted.map { Pos($0) })) == Set([])
            expect(Set(deleted.map { Pos($0) })) == Set([Pos(M("1",1),0),Pos(M("4",4),1)])
            expect(Set(updated.map { Pos($0) })) == Set([Pos(M("5",5),0),Pos(M("6",6),1),Pos(M("8",8),2)])
            expect(Set(moved.map { MovedPos($0) })) == Set([])
        }
        it("should return the correct tuple when inserted 7,9 : ([5,6,8] -> [5,6,7,8,9]") {
            let oldList = [5,6,8].map { M("\($0)",$0) }
            let newList = [5,6,7,8,9].map { M("\($0)",$0) }
            let (inserted ,deleted ,updated, moved)  = oldList.transformTo(newList: newList, sortedBy : M.compare)
            expect(Set(inserted.map { Pos($0) } )) == Set([Pos(M("7",7),2),Pos(M("9",9),4)])
            expect(Set(deleted.map { Pos($0) })) == Set([])
            expect(Set(updated.map { Pos($0) })) == Set([Pos(M("5",5),0),Pos(M("6",6),1),Pos(M("8",8),3)])
            expect(Set(moved.map { MovedPos($0) })) == Set([])
        }
        it("should return the correct tuple when moved 8 to first position: ([5,6,7,8,9] -> [8,5,6,7,9]") {
            let oldList = [5,6,7,8,9].map { M("\($0)",$0) }
            let newList =  [M("8",0),M("5",5),M("6",6),M("7",7),M("9",9)]
            let (inserted ,deleted ,updated, moved)  = oldList.transformTo(newList: newList, sortedBy : M.compare)
            expect(Set(inserted.map { Pos($0) })) == Set([])
            expect(Set(deleted.map { Pos($0) })) == Set([])
            expect(Set(updated.map { Pos($0) })) == Set([Pos(M("5",5),1),Pos(M("6",6),2),Pos(M("7",7),3),Pos(M("9",9),4)])
            expect(Set(moved.map { MovedPos($0) })) == Set([MovedPos(M("8",0),3,0)])
        }
        it("should return the correct tuple when moved 7 to 2nd position: ([5,6,7,8,9] -> [8,5,6,7,9]") {
            let oldList = [M("8",0),M("5",5),M("6",6),M("7",7),M("9",9)]
            let newList =  [M("8",0),M("7",1),M("5",5),M("6",6),M("9",9)]
            let (inserted ,deleted ,updated, moved)  = oldList.transformTo(newList: newList, sortedBy : M.compare)
            expect(Set(inserted.map { Pos($0) })) == Set([])
            expect(Set(deleted.map { Pos($0) })) == Set([])
            expect(Set(updated.map { Pos($0) })) == Set([Pos(M("8",0),0),Pos(M("5",5),2),Pos(M("6",6),3),Pos(M("9",9),4)])
            expect(Set(moved.map { MovedPos($0) })) == Set([MovedPos(M("7",1),3,1)])
        }
        
        it("should return the correct tuple when moved 5 to the end plus 2 new inserts: ([1,5] -> [3,1,2,5]") {
            let oldList = [1,5].map { M("\($0)",$0) }
            let newList =  [M("1",1),M("2",2),M("3",3),M("5",5)]
            let (inserted ,deleted ,updated, moved)  = oldList.transformTo(newList: newList, sortedBy : M.compare)
            expect(Set(inserted.map { Pos($0) })) == Set([Pos(M("2",2),1),Pos(M("3",3),2)])
            expect(Set(deleted.map { Pos($0) })) == Set([])
            expect(Set(updated.map { Pos($0) })) == Set([Pos(M("1",1),0),Pos(M("5",5),3)])
            expect(Set(moved.map { MovedPos($0) })) == Set([])
        }
        it("should return the correct tuple when moving 1 to next pos and inserting 2: ([1,3,5] -> [3,1,2,5]") {
            let oldList = [1,3,5].map { M("\($0)",$0) }
            let newList =  [M("3",0),M("1",1),M("2",2),M("5",5)]
            let (inserted ,deleted ,updated, moved)  = oldList.transformTo(newList: newList, sortedBy : M.compare)
            expect(Set(inserted.map { Pos($0) })) == Set([Pos(M("2",2),2)])
            expect(Set(deleted.map { Pos($0) })) == Set([])
            expect(Set(updated.map { Pos($0) })) == Set([Pos(M("3",0),0),Pos(M("5",5),3)])
            expect(Set(moved.map { MovedPos($0) })) == Set([MovedPos(M("1",1),0,1)])
        }
        it("should return the correct tuple when deleting 1 to next pos and inserting 2: ([1,3,5] -> [3,2,5]") {
            let oldList = [1,3,5].map { M("\($0)",$0) }
            let newList =  [M("3",0),M("2",2),M("5",5)]
            let (inserted ,deleted ,updated, moved)  = oldList.transformTo(newList: newList, sortedBy : M.compare)
            expect(Set(inserted.map { Pos($0) })) == Set([Pos(M("2",2),1)])
            expect(Set(deleted.map { Pos($0) })) == Set([Pos(M("1",1),0)])
            expect(Set(updated.map { Pos($0) })) == Set([Pos(M("3",0),0),Pos(M("5",5),2)])
            expect(Set(moved.map { MovedPos($0) })) == Set([])
        }

    }
}