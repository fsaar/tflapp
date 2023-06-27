//
//  TFLBusStationInfo.swift
//  tflapp
//
//  Created by Frank Saar on 20/06/2023.
//  Copyright © 2023 SAMedialabs. All rights reserved.
//

import Foundation
import SwiftData
import CoreLocation

/*
 {
            "$type": "Tfl.Api.Presentation.Entities.StopPoint, Tfl.Api.Presentation.Entities",
            "naptanId": "490015185H",
            "indicator": "Stop H",
            "stopLetter": "H",
            "modes": [
                "bus"
            ],
            "icsCode": "1011791",
            "stopType": "NaptanPublicBusCoachTram",
            "stationNaptan": "490G00011791",
            "lines": [],
            "lineGroup": [],
            "lineModeGroups": [],
            "status": true,
            "id": "490015185H",
            "commonName": "Trocadero / Haymarket",
            "distance": 58.808450139207579,
            "placeType": "StopPoint",
            "additionalProperties": [
                {
                    "$type": "Tfl.Api.Presentation.Entities.AdditionalProperties, Tfl.Api.Presentation.Entities",
                    "category": "Direction",
                    "key": "CompassPoint",
                    "sourceSystemKey": "Naptan490",
                    "value": "N"
                },
                {
                    "$type": "Tfl.Api.Presentation.Entities.AdditionalProperties, Tfl.Api.Presentation.Entities",
                    "category": "Direction",
                    "key": "Towards",
                    "sourceSystemKey": "CountDown",
                    "value": "Holborn or Warren Street Station"
                }
            ],
            "children": [],
            "lat": 51.510514,
            "lon": -0.134197
        },
       
*/


@Model
public final class TFLBusStation : Identifiable,Decodable,Hashable,Equatable {
    private enum CodingKeys : String,CodingKey {
        case naptanId = "naptanId"
        case stationNaptan = "stationNaptan"
        case commonName = "commonName"
        case latitude = "lat"
        case longitude = "lon"
        case stopType = "stopType"
        case stopLetter = "stopLetter"
        case status = "status"
        case additionalProperties = "additionalProperties"
        case lines = "lines"
        case towardsKeyValue = "Towards"
    }
    
    static public func ==(lhs: TFLBusStation, rhs: TFLBusStation) -> Bool {
        return lhs.identifier == rhs.identifier
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.identifier)
    }
    
    struct AdditionalProperties : Decodable {
        let category : String
        let key : String
        let value : String
    }
    
    struct Line : Decodable {
        let id : String
        let name : String
        let type : String
    }

    @Attribute(.unique) var identifier: String
    var stationIdentifier: String?
    var lat: Double
    var long: Double
    var name: String
    var status: Bool
    var stopLetter: String?
    var towards: String?
    var lines: [String]
    
    var location : CLLocation {
        CLLocation(latitude: lat, longitude: long)
    }
    
    public var id: String {
        return self.identifier
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let additionalProperties = try container.decode([AdditionalProperties].self, forKey: .additionalProperties)
        identifier = try container.decode(String.self, forKey: .naptanId)
        stationIdentifier = try container.decodeIfPresent(String.self, forKey: .stationNaptan)
        lat = try container.decode(Double.self, forKey: .latitude)
        long = try container.decode(Double.self, forKey: .longitude)
      
        name = try container.decode(String.self, forKey: .commonName)
       
        status = try container.decodeIfPresent(Bool.self, forKey: .status) ?? false
        stopLetter = try container.decodeIfPresent(String.self, forKey: .stopLetter)
        let towardsInfo = additionalProperties.first { $0.key == CodingKeys.towardsKeyValue.rawValue }
        towards = towardsInfo?.value
        let linesList : [Line] = try container.decodeIfPresent([Line].self, forKey: .lines) ?? []
        lines = linesList.map { $0.id }
    }
}
