//
//  TFLLine.swift
//  tflapp
//
//  Created by Frank Saar on 16/08/2023.
//  Copyright © 2023 SAMedialabs. All rights reserved.
//

import Foundation
import SwiftData


struct TFLLineInfo: Decodable {
    private enum Identifiers : String {
           case lineId = "lineId"
           case routes = "orderedLineRoutes"
       }
    private enum CodingKeys : String,CodingKey {
        case lineId = "lineId"
        case routes = "orderedLineRoutes"
    }
   
//    var lastUpdated: Date
//    var identifier: String
//    var routes: [String]
    
    public init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        let additionalProperties = try container.decode([AdditionalProperties].self, forKey: .additionalProperties)
//        identifier = try container.decode(String.self, forKey: .naptanId)
    }
}
