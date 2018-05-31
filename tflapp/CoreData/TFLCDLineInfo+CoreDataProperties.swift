//
//  TFLCDLineInfo+CoreDataProperties.swift
//  
//
//  Created by Frank Saar on 31/05/2018.
//
//

import Foundation
import CoreData


extension TFLCDLineInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TFLCDLineInfo> {
        return NSFetchRequest<TFLCDLineInfo>(entityName: "TFLCDLineInfo")
    }

    @NSManaged public var identifier: String
    @NSManaged public var route: NSOrderedSet?

}

// MARK: Generated accessors for route
extension TFLCDLineInfo {

    @objc(insertObject:inRouteAtIndex:)
    @NSManaged public func insertIntoRoute(_ value: TFLLineRoute, at idx: Int)

    @objc(removeObjectFromRouteAtIndex:)
    @NSManaged public func removeFromRoute(at idx: Int)

    @objc(insertRoute:atIndexes:)
    @NSManaged public func insertIntoRoute(_ values: [TFLLineRoute], at indexes: NSIndexSet)

    @objc(removeRouteAtIndexes:)
    @NSManaged public func removeFromRoute(at indexes: NSIndexSet)

    @objc(replaceObjectInRouteAtIndex:withObject:)
    @NSManaged public func replaceRoute(at idx: Int, with value: TFLLineRoute)

    @objc(replaceRouteAtIndexes:withRoute:)
    @NSManaged public func replaceRoute(at indexes: NSIndexSet, with values: [TFLLineRoute])

    @objc(addRouteObject:)
    @NSManaged public func addToRoute(_ value: TFLLineRoute)

    @objc(removeRouteObject:)
    @NSManaged public func removeFromRoute(_ value: TFLLineRoute)

    @objc(addRoute:)
    @NSManaged public func addToRoute(_ values: NSOrderedSet)

    @objc(removeRoute:)
    @NSManaged public func removeFromRoute(_ values: NSOrderedSet)

}
