//
//  GoogleRouteInfo.swift
//  tflapp
//
//  Created by Frank Saar on 18/03/2019.
//  Copyright © 2019 SAMedialabs. All rights reserved.
//

import Foundation

#if DEBUG
struct GoogleRouteInfo : Decodable {
    enum RoutesCodingKeys: String, CodingKey {
        case routes = "routes"
    }
    enum PolyLineKeys : String,CodingKey {
        case overviewPolyline = "overview_polyline"
    }
    enum CodingKeys : String, CodingKey {
        case points = "points"
    }
    let polyline : String
    public init(from decoder: Decoder) throws {
        let routesContainer = try decoder.container(keyedBy: RoutesCodingKeys.self)
        var list = try routesContainer.nestedUnkeyedContainer(forKey: RoutesCodingKeys.routes)
        let polylineContainer = try list.nestedContainer(keyedBy: PolyLineKeys.self)
        let pointsContainer = try polylineContainer.nestedContainer(keyedBy: CodingKeys.self, forKey: PolyLineKeys.overviewPolyline)
        polyline = try pointsContainer.decodeIfPresent(String.self, forKey: CodingKeys.points) ?? ""
    }
}
#endif
