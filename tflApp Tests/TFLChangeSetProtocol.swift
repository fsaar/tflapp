import Foundation
import Nimble
import UIKit
import Quick
import CoreData

@testable import London_Bus

fileprivate struct TFLChangeSetHandler : TFLChangeSetProtocol { }

fileprivate struct D : Equatable,Hashable {
    let a : M
    let b : Int
    init(_ a: M,_ b: Int) {
        self.a = a
        self.b = b
    }
    var hashValue: Int {
        return "\(a),\(b)".hashValue
    }
    
    static public func ==(lhs : D, rhs : D) -> Bool {
        return (lhs.a == rhs.a) && (rhs.b == lhs.b)
    }
}

fileprivate struct T : Equatable,Hashable {
    let a : M
    let b : Int
    let c : Int
    init(_ a: M,_ b: Int,_ c: Int) {
        self.a = a
        self.b = b
        self.c = c
    }
    var hashValue: Int {
        return "\(a),\(b),\(c)".hashValue
    }
    
    static public func ==(lhs : T, rhs : T) -> Bool {
        return (lhs.a == rhs.a) && (rhs.b == lhs.b) && (rhs.c == lhs.c)
    }
}


fileprivate struct M : CustomDebugStringConvertible,Hashable {
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
    
    var debugDescription: String { return "[\(id)]\(x)" } //tempList
    var hashValue: Int  { return id.hashValue }
}

class TFLChangeSetProtocolSpecs : QuickSpec {
    
    override func spec() {
        var changeSetHandler : TFLChangeSetHandler!
        beforeEach {
            changeSetHandler = TFLChangeSetHandler()
        }
        it("should return the correct tuple when nothing's been inserted : [] -> []") {
            let newList : [M] = []
            let (inserted ,deleted ,updated, moved)  = changeSetHandler.evaluateLists(oldList: [], newList: newList, compare : M.compare)
            expect(Set(inserted.map { D($0,$1) })) == Set([])
            expect(Set(deleted.map { D($0,$1) })) == Set([])
            expect(Set(updated.map { D($0,$1) })) == Set([])
            expect(Set(moved.map { T($0,$1,$2) })) == Set([])
            
        }
        
        it("should return the correct tuple when inserted 1,2,4,6,8 : [] -> [1,2,4,6,8]") {
            let newList = [1,2,4,6,8].map { M("\($0)",$0) }
            let (inserted ,deleted ,updated, moved)  = changeSetHandler.evaluateLists(oldList: [], newList: newList, compare : M.compare)
            expect(Set(inserted.map { D($0,$1) })) == Set([D(M("1",1),0),D(M("2",2),1),D(M("4",4),2),D(M("6",6),3),D(M("8",8),4)])
            expect(Set(deleted.map { D($0,$1) })) == Set([])
            expect(Set(updated.map { D($0,$1) })) == Set([])
            expect(Set(moved.map { T($0,$1,$2) })) == Set([])
        }
        
        it("should return the correct tuple when nothing's changed : [1,2,4,6,8] -> [1,2,4,6,8]") {
            let oldList = [1,2,4,6,8].map { M("\($0)",$0) }
            let newList = [1,2,4,6,8].map { M("\($0)",$0) }
            let (inserted ,deleted ,updated, moved)  = changeSetHandler.evaluateLists(oldList: oldList, newList: newList, compare : M.compare)
            expect(Set(inserted.map { D($0,$1) })) == Set([])
            expect(Set(deleted.map { D($0,$1) })) == Set([])
            expect(Set(updated.map { D($0,$1) })) == Set([D(M("1",1),0),D(M("2",2),1),D(M("4",4),2),D(M("6",6),3),D(M("8",8),4)])
            expect(Set(moved.map { T($0,$1,$2) })) == Set([])
            
        }

        it("should return the correct tuple when everything's removed : [1,2,4,6,8] -> []") {
            let oldList = [1,2,4,6,8].map { M("\($0)",$0) }
            let (inserted ,deleted ,updated, moved)  = changeSetHandler.evaluateLists(oldList: oldList, newList: [], compare : M.compare)
            expect(Set(inserted.map { D($0,$1) })) == Set([])
            expect(Set(deleted.map { D($0,$1) })) == Set([D(M("1",1),0),D(M("2",2),1),D(M("4",4),2),D(M("6",6),3),D(M("8",8),4)])
            expect(Set(updated.map { D($0,$1) })) == Set([])
            expect(Set(moved.map { T($0,$1,$2) })) == Set([])
            
        }

        it("should return the correct tuple when inserted 5 : ([1,2,4,6,8] -> [1,2,4,5,6,8]") {
            let oldList = [1,2,4,6,8].map { M("\($0)",$0) }
            let newList = [1,2,4,5,6,8].map { M("\($0)",$0) }
            let (inserted ,deleted ,updated, moved)  = changeSetHandler.evaluateLists(oldList: oldList, newList: newList, compare : M.compare)
            expect(Set(inserted.map { D($0,$1) })) == Set([D(M("5",5),3)])
            expect(Set(deleted.map { D($0,$1) })) == Set([])
            expect(Set(updated.map { D($0,$1) })) == Set([D(M("1",1),0),D(M("2",2),1),D(M("4",4),2),D(M("6",6),4),D(M("8",8),5)])
            expect(Set(moved.map { T($0,$1,$2) })) == Set([])
        }
        it("should return the correct tuple when deleted 2 : ([1,2,4,5,6,8] -> [1,4,5,6,8]") {
            let oldList = [1,2,4,5,6,8].map { M("\($0)",$0) }
            let newList = [1,4,5,6,8].map { M("\($0)",$0) }
            let (inserted ,deleted ,updated, moved)  = changeSetHandler.evaluateLists(oldList: oldList, newList: newList, compare : M.compare)
            expect(Set(inserted.map { D($0,$1) })) == Set([])
            expect(Set(deleted.map { D($0,$1) })) == Set([D(M("2",2),1)])
            expect(Set(updated.map { D($0,$1) })) == Set([D(M("1",1),0),D(M("4",4),1),D(M("5",5),2),D(M("6",6),3),D(M("8",8),4)])
            expect(Set(moved.map { T($0,$1,$2) })) == Set([])
        }
        it("should return the correct tuple when deleted 1,4 : ([1,4,5,6,8] -> [5,6,8]") {
            let oldList = [1,4,5,6,8].map { M("\($0)",$0) }
            let newList = [5,6,8].map { M("\($0)",$0) }
            let (inserted ,deleted ,updated, moved)  = changeSetHandler.evaluateLists(oldList: oldList, newList: newList, compare : M.compare)
            expect(Set(inserted.map { D($0,$1) })) == Set([])
            expect(Set(deleted.map { D($0,$1) })) == Set([D(M("1",1),0),D(M("4",4),1)])
            expect(Set(updated.map { D($0,$1) })) == Set([D(M("5",5),0),D(M("6",6),1),D(M("8",8),2)])
            expect(Set(moved.map { T($0,$1,$2) })) == Set([])
        }
        it("should return the correct tuple when inserted 7,9 : ([5,6,8] -> [5,6,7,8,9]") {
            let oldList = [5,6,8].map { M("\($0)",$0) }
            let newList = [5,6,7,8,9].map { M("\($0)",$0) }
            let (inserted ,deleted ,updated, moved)  = changeSetHandler.evaluateLists(oldList: oldList, newList: newList, compare : M.compare)
            expect(Set(inserted.map { D($0,$1) })) == Set([D(M("7",7),2),D(M("9",9),4)])
            expect(Set(deleted.map { D($0,$1) })) == Set([])
            expect(Set(updated.map { D($0,$1) })) == Set([D(M("5",5),0),D(M("6",6),1),D(M("8",8),3)])
            expect(Set(moved.map { T($0,$1,$2) })) == Set([])
        }
        it("should return the correct tuple when moved 8 to first position: ([5,6,7,8,9] -> [8,5,6,7,9]") {
            let oldList = [5,6,7,8,9].map { M("\($0)",$0) }
            let newList =  [M("8",0),M("5",5),M("6",6),M("7",7),M("9",9)]
            let (inserted ,deleted ,updated, moved)  = changeSetHandler.evaluateLists(oldList: oldList, newList: newList, compare : M.compare)
            expect(Set(inserted.map { D($0,$1) })) == Set([])
            expect(Set(deleted.map { D($0,$1) })) == Set([])
            expect(Set(updated.map { D($0,$1) })) == Set([D(M("5",5),1),D(M("6",6),2),D(M("7",7),3),D(M("9",9),4)])
            expect(Set(moved.map { T($0,$1,$2) })) == Set([T(M("8",0),3,0)])
        }
        it("should return the correct tuple when moved 7 to 2nd position: ([5,6,7,8,9] -> [8,5,6,7,9]") {
            let oldList = [M("8",0),M("5",5),M("6",6),M("7",7),M("9",9)]
            let newList =  [M("8",0),M("7",1),M("5",5),M("6",6),M("9",9)]
            let (inserted ,deleted ,updated, moved)  = changeSetHandler.evaluateLists(oldList: oldList, newList: newList, compare : M.compare)
            expect(Set(inserted.map { D($0,$1) })) == Set([])
            expect(Set(deleted.map { D($0,$1) })) == Set([])
            expect(Set(updated.map { D($0,$1) })) == Set([D(M("8",0),0),D(M("5",5),2),D(M("6",6),3),D(M("9",9),4)])
            expect(Set(moved.map { T($0,$1,$2) })) == Set([T(M("7",1),3,1)])
        }

    }
}
