//
//  TFLCDLineRoute+CoreDataProperties.swift
//  
//
//  Created by Frank Saar on 16/02/2019.
//
//

import Foundation
import CoreData
import MapKit

extension TFLCDLineRoute {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TFLCDLineRoute> {
        return NSFetchRequest<TFLCDLineRoute>(entityName: "TFLCDLineRoute")
    }

    @NSManaged public var name: String
    @NSManaged public var stations: [String]?
    @NSManaged public var serviceType: String
    @NSManaged public var polyline: String?
    @NSManaged public var line: TFLCDLineInfo?

}
