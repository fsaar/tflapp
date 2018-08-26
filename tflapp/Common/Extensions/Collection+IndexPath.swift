import UIKit
import Foundation

extension Collection where Element == Int  {
    func indexPaths(_ section : Int = 0) -> [IndexPath] {
        return self.map { IndexPath(item: $0, section: section) }
    }
}
