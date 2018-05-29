//
//  TFLCDLineInfo+CoreDataProperties.swift
//  tflapp
//
//  Created by Frank Saar on 29/05/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//
//

import Foundation
import CoreData


extension TFLCDLineInfo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TFLCDLineInfo> {
        return NSFetchRequest<TFLCDLineInfo>(entityName: "TFLCDLineInfo")
    }

    @NSManaged public var identifier: String
    @NSManaged public var stations: NSOrderedSet?

}

// MARK: Generated accessors for stations
extension TFLCDLineInfo {

    @objc(insertObject:inStationsAtIndex:)
    @NSManaged public func insertIntoStations(_ value: TFLCDStation, at idx: Int)

    @objc(removeObjectFromStationsAtIndex:)
    @NSManaged public func removeFromStations(at idx: Int)

    @objc(insertStations:atIndexes:)
    @NSManaged public func insertIntoStations(_ values: [TFLCDStation], at indexes: NSIndexSet)

    @objc(removeStationsAtIndexes:)
    @NSManaged public func removeFromStations(at indexes: NSIndexSet)

    @objc(replaceObjectInStationsAtIndex:withObject:)
    @NSManaged public func replaceStations(at idx: Int, with value: TFLCDStation)

    @objc(replaceStationsAtIndexes:withStations:)
    @NSManaged public func replaceStations(at indexes: NSIndexSet, with values: [TFLCDStation])

    @objc(addStationsObject:)
    @NSManaged public func addToStations(_ value: TFLCDStation)

    @objc(removeStationsObject:)
    @NSManaged public func removeFromStations(_ value: TFLCDStation)

    @objc(addStations:)
    @NSManaged public func addToStations(_ values: NSOrderedSet)

    @objc(removeStations:)
    @NSManaged public func removeFromStations(_ values: NSOrderedSet)

}
