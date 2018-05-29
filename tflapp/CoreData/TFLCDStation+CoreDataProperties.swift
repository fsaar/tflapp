//
//  TFLCDStation+CoreDataProperties.swift
//  tflapp
//
//  Created by Frank Saar on 29/05/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//
//

import Foundation
import CoreData


extension TFLCDStation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TFLCDStation> {
        return NSFetchRequest<TFLCDStation>(entityName: "TFLCDStation")
    }

    @NSManaged public var identifier: String
    @NSManaged public var lat: Double
    @NSManaged public var long: Double
    @NSManaged public var name: String?
    @NSManaged public var lineInfos: NSSet?

}

// MARK: Generated accessors for lineInfos
extension TFLCDStation {

    @objc(addLineInfosObject:)
    @NSManaged public func addToLineInfos(_ value: TFLCDLineInfo)

    @objc(removeLineInfosObject:)
    @NSManaged public func removeFromLineInfos(_ value: TFLCDLineInfo)

    @objc(addLineInfos:)
    @NSManaged public func addToLineInfos(_ values: NSSet)

    @objc(removeLineInfos:)
    @NSManaged public func removeFromLineInfos(_ values: NSSet)

}
