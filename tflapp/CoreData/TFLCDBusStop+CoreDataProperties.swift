//
//  TFLCDBusStop+CoreDataProperties.swift
//  
//
//  Created by Frank Saar on 27/05/2018.
//
//

import Foundation
import CoreData


extension TFLCDBusStop {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TFLCDBusStop> {
        return NSFetchRequest<TFLCDBusStop>(entityName: "TFLCDBusStop")
    }

    @NSManaged public var identifier: String
    @NSManaged public var lat: Double
    @NSManaged public var long: Double
    @NSManaged public var name: String
    @NSManaged public var status: Bool
    @NSManaged public var stopLetter: String?
    @NSManaged public var towards: String?

}
