import Foundation
import Nimble
import UIKit
import Quick
import CoreData

@testable import London_Bus

fileprivate struct TFLChangeSetHandler : TFLChangeSetProtocol { }

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

fileprivate class TFLTransitionableTableView : UITableView,UITableViewDelegate {
    var insertedBlock : (([IndexPath]) -> ())?
    var deletedBlock : (([IndexPath]) -> ())?
    var movedBlock : ((IndexPath,IndexPath) -> ())?
    
    override func insertRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation) {
        self.insertedBlock?(indexPaths)
    }
    
    override func deleteRows(at indexPaths: [IndexPath], with animation: UITableViewRowAnimation) {
        self.deletedBlock?(indexPaths)
    }
    
    override func moveRow(at indexPath: IndexPath, to newIndexPath: IndexPath) {
        self.movedBlock?(indexPath,newIndexPath)
    }

}

class TFLTransitionableSpecs : QuickSpec {
    

    override func spec() {
        var tableView : TFLTransitionableTableView!
        beforeEach {
            
            tableView = TFLTransitionableTableView()
        }
        context("when dealing with UITableview's TFLTransitionable conformance ") {
            func insertionTest(tableView : TFLTransitionableTableView, oldList : [M],newList : [M]) -> (Bool) {
                let changeSetHandler = TFLChangeSetHandler()
                var hasCorrectIndexPaths = false
                let (inserted ,_ ,_, _)  = changeSetHandler.evaluateLists(oldList: oldList, newList: newList, compare : M.compare)
                let insertedIndexPaths = inserted.map { IndexPath(row: $0.index,section:0) }
                tableView.insertedBlock = { indexPaths in
                    hasCorrectIndexPaths = Set(insertedIndexPaths) == Set(indexPaths)
                }
                tableView.transition(from: oldList, to: newList, with: M.compare) { _ in }
                return hasCorrectIndexPaths
            }
            func deletionTest(tableView : TFLTransitionableTableView, oldList : [M],newList : [M]) -> (Bool) {
                let changeSetHandler = TFLChangeSetHandler()
                var hasCorrectIndexPaths = false
                let (_ ,deleted ,_, _)  = changeSetHandler.evaluateLists(oldList: oldList, newList: newList, compare : M.compare)
                let deletedIndexPaths = deleted.map { IndexPath(row: $0.index,section:0) }
                tableView.deletedBlock = { indexPaths in
                    hasCorrectIndexPaths = Set(deletedIndexPaths) == Set(indexPaths)
                }
                tableView.transition(from: oldList, to: newList, with: M.compare) { _ in }
                return hasCorrectIndexPaths
            }
            
            func updateTest(tableView : TFLTransitionableTableView, oldList : [M],newList : [M]) -> (Bool) {
                let changeSetHandler = TFLChangeSetHandler()
                var hasCorrectIndexPaths = false
                let (_ ,_ ,updated, moved)  = changeSetHandler.evaluateLists(oldList: oldList, newList: newList, compare : M.compare)
                let updatedIndexPaths = updated.map { IndexPath(row: $0.index,section:0) }
                let movedIndexPaths = moved.map { IndexPath(row: $0.newIndex,section:0) }
                tableView.transition(from: oldList, to: newList, with: M.compare) { indexPaths in
                    hasCorrectIndexPaths = Set(updatedIndexPaths+movedIndexPaths) == Set(indexPaths)
                }
                return hasCorrectIndexPaths
            }
            
            func moveTest(tableView : TFLTransitionableTableView, oldList : [M],newList : [M]) -> (Bool) {
                let changeSetHandler = TFLChangeSetHandler()
                let (_ ,_ ,_, moved)  = changeSetHandler.evaluateLists(oldList: oldList, newList: newList, compare : M.compare)
                var oldMovedIndexPathContainer : [IndexPath] = []
                var newMovedIndexPathContainer : [IndexPath] = []
                let newMovedIndexPaths = moved.map { IndexPath(row: $0.newIndex,section:0) }
                let oldMovedIndexPaths = moved.map { IndexPath(row: $0.oldIndex,section:0) }
                tableView.movedBlock = { oldIndexPath,newIndexPath in
                    oldMovedIndexPathContainer += [oldIndexPath]
                    newMovedIndexPathContainer += [newIndexPath]
                }
                tableView.transition(from: oldList, to: newList, with: M.compare) { _ in }
                let hasCorrectOldIndexPaths = Set(oldMovedIndexPaths) == Set(oldMovedIndexPathContainer)
                let hasCorrectNewIndexPaths = Set(newMovedIndexPaths) == Set(newMovedIndexPathContainer)
                let hasCorrectIndexPaths = hasCorrectNewIndexPaths && hasCorrectOldIndexPaths
                return hasCorrectIndexPaths
            }
            

            describe("in regards to insertion") {
                it("should return the right indices for indexPaths to be inserted : [] -> [1,2,4,6,8]") {
                    let oldList : [M] = []
                    let newList = [1,2,4,6,8].map { M("\($0)",$0) }
                    let hasCorrectIndexPaths = insertionTest(tableView: tableView, oldList: oldList, newList: newList)
                    expect(hasCorrectIndexPaths) == true
                }
                it("should return the right indices for indexPaths to be inserted : [] -> []") {
                    let oldList : [M] = []
                    let newList  : [M] = []
                    let hasCorrectIndexPaths = insertionTest(tableView: tableView, oldList: oldList, newList: newList)
                    expect(hasCorrectIndexPaths) == true
                }
                it("should return the right indices for indexPaths to be inserted : [1,2,4,6,8] -> []") {
                    let oldList : [M] = [1,2,4,6,8].map { M("\($0)",$0) }
                    let newList  : [M] = [1,2,4,6,8].map { M("\($0)",$0) }
                    let hasCorrectIndexPaths = insertionTest(tableView: tableView, oldList: oldList, newList: newList)
                    expect(hasCorrectIndexPaths) == true
                }
            }

            describe("in regards to deletion") {

                it("should return the right indices for indexPaths to be deleted : [1,2,4,6,8] -> []") {
                    let oldList : [M] = [1,2,4,6,8].map { M("\($0)",$0) }
                    let newList : [M] = []
                    let hasCorrectIndexPaths = deletionTest(tableView: tableView, oldList: oldList, newList: newList)
                    expect(hasCorrectIndexPaths) == true
                    
                }
                it("should return the right indices for indexPaths to be deleted : [] -> [1,2,4,6,8]") {
                    let oldList : [M] = []
                    let newList = [1,2,4,6,8].map { M("\($0)",$0) }
                    let hasCorrectIndexPaths = deletionTest(tableView: tableView, oldList: oldList, newList: newList)
                    expect(hasCorrectIndexPaths) == true
                }
                
                it("should return the right indices for indexPaths to be deleted : [] -> []") {
                    let oldList : [M] = []
                    let newList  : [M] = []
                    let hasCorrectIndexPaths = deletionTest(tableView: tableView, oldList: oldList, newList: newList)
                    expect(hasCorrectIndexPaths) == true
                }
            }

            describe("in regards to updates") {
                it("should return the right indices for indexPaths to be updated : [1,2,4,6,8] -> []") {
                    let oldList : [M] = [1,2,4,6,8].map { M("\($0)",$0) }
                    let newList : [M] = []
                    let hasCorrectIndexPaths = updateTest(tableView: tableView, oldList: oldList, newList: newList)
                    expect(hasCorrectIndexPaths) == true
                    
                }
                it("should return the right indices for indexPaths to be updated : [] -> [1,2,4,6,8]") {
                    let oldList : [M] = []
                    let newList = [1,2,4,6,8].map { M("\($0)",$0) }
                    let hasCorrectIndexPaths = updateTest(tableView: tableView, oldList: oldList, newList: newList)
                    expect(hasCorrectIndexPaths) == true
                }
                
                it("should return the right indices for indexPaths to be updated : [] -> []") {
                    let oldList : [M] = []
                    let newList  : [M] = []
                    let hasCorrectIndexPaths = updateTest(tableView: tableView, oldList: oldList, newList: newList)
                    expect(hasCorrectIndexPaths) == true
                }

                it("should return the right indices for indexPaths to be updated : [5,6,7,8,9] -> [8,6,5,7,9]") {
                    let oldList = [5,6,7,8,9].map { M("\($0)",$0) }
                    let newList =  [M("8",0),M("5",5),M("6",6),M("7",7),M("9",9)]
                    let hasCorrectIndexPaths = updateTest(tableView: tableView, oldList: oldList, newList: newList)
                    expect(hasCorrectIndexPaths) == true
                }
            }

            describe("in regards to moves") {
                it("should return the right indices for indexPaths to be moved : [5,6,7,8,9] -> [8,6,5,7,9]") {
                    let oldList = [5,6,7,8,9].map { M("\($0)",$0) }
                    let newList =  [M("8",0),M("5",5),M("6",6),M("7",7),M("9",9)]
                    let hasCorrectIndexPaths = moveTest(tableView: tableView, oldList: oldList, newList: newList)
                    expect(hasCorrectIndexPaths) == true
                }
                it("should return the right indices for indexPaths to be moved : [5,6,7,8,9] -> [8,5,6,7,9]") {
                    let oldList = [M("8",0),M("5",5),M("6",6),M("7",7),M("9",9)]
                    let newList =  [M("8",0),M("7",1),M("5",5),M("6",6),M("9",9)]
                    let hasCorrectIndexPaths = moveTest(tableView: tableView, oldList: oldList, newList: newList)
                    expect(hasCorrectIndexPaths) == true
                }
            }

        }
    }
}
