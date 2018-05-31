//
//  TFLLineRoute+CoreDataProperties.swift
//  
//
//  Created by Frank Saar on 31/05/2018.
//
//

import Foundation
import CoreData


extension TFLLineRoute {
    @NSManaged public var name: String
    @NSManaged public var stations: [String]?
    @NSManaged public var serviceType: String
    @NSManaged public var line: TFLCDLineInfo?

}
