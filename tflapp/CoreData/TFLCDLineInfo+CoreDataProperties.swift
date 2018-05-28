//
//  TFLCDLineInfo+CoreDataProperties.swift
//  tflapp
//
//  Created by Frank Saar on 28/05/2018.
//  Copyright © 2018 SAMedialabs. All rights reserved.
//
//

import Foundation
import CoreData


extension TFLCDLineInfo {

    @NSManaged public var identifier: String
    @NSManaged public var stations: [String]?

}
