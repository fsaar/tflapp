//
//  TFLCDLineInfo+CoreDataProperties.swift
//  tflapp
//
//  Created by Frank Saar on 31/05/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//
//

import Foundation
import CoreData


extension TFLCDLineInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TFLCDLineInfo> {
        return NSFetchRequest<TFLCDLineInfo>(entityName: "TFLCDLineInfo")
    }

    @NSManaged public var identifier: String?
    @NSManaged public var routes: NSOrderedSet?

}

// MARK: Generated accessors for routes
extension TFLCDLineInfo {

    @objc(insertObject:inRoutesAtIndex:)
    @NSManaged public func insertIntoRoutes(_ value: TFLCDLineRoute, at idx: Int)

    @objc(removeObjectFromRoutesAtIndex:)
    @NSManaged public func removeFromRoutes(at idx: Int)

    @objc(insertRoutes:atIndexes:)
    @NSManaged public func insertIntoRoutes(_ values: [TFLCDLineRoute], at indexes: NSIndexSet)

    @objc(removeRoutesAtIndexes:)
    @NSManaged public func removeFromRoutes(at indexes: NSIndexSet)

    @objc(replaceObjectInRoutesAtIndex:withObject:)
    @NSManaged public func replaceRoutes(at idx: Int, with value: TFLCDLineRoute)

    @objc(replaceRoutesAtIndexes:withRoutes:)
    @NSManaged public func replaceRoutes(at indexes: NSIndexSet, with values: [TFLCDLineRoute])

    @objc(addRoutesObject:)
    @NSManaged public func addToRoutes(_ value: TFLCDLineRoute)

    @objc(removeRoutesObject:)
    @NSManaged public func removeFromRoutes(_ value: TFLCDLineRoute)

    @objc(addRoutes:)
    @NSManaged public func addToRoutes(_ values: NSOrderedSet)

    @objc(removeRoutes:)
    @NSManaged public func removeFromRoutes(_ values: NSOrderedSet)

}
