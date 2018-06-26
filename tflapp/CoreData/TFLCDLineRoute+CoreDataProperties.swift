//
//  TFLCDLineRoute+CoreDataProperties.swift
//  tflapp
//
//  Created by Frank Saar on 31/05/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//
//

import Foundation
import CoreData


extension TFLCDLineRoute {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TFLCDLineRoute> {
        return NSFetchRequest<TFLCDLineRoute>(entityName: "TFLCDLineRoute")
    }

    @NSManaged public var name: String
    @NSManaged public var stations: [String]?
    @NSManaged public var serviceType: String
    @NSManaged public var line: TFLCDLineInfo?

}
