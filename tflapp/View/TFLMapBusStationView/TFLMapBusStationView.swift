//
//  TFLMapBusStationView.swift
//  tflapp
//
//  Created by Frank Saar on 11/07/2023.
//  Copyright © 2023 SAMedialabs. All rights reserved.
//

import Foundation
import SwiftUI
import MapKit
import OSLog

struct TFLMapBusStationView : View {
    @Environment(TFLStationList.self) private var stationList 
    @Environment(TFLBusstationSelection.self) private var stationSelection
    @State private var position : MapCameraPosition = .automatic
    @State private var selection : String?
    fileprivate let logger : Logger =  {
        let handle = Logger(subsystem: TFLLogger.subsystem, category: TFLLogger.category.map.rawValue)
        return handle
    }()
    var body : some View {
        Map(position:$position, selection:$selection) {
            ForEach(stationList.list) { station in
                Marker(station.name,
                       systemImage: "bus.doubledecker.fill",
                       coordinate:  station.location.coordinate)
                .tint(.tflMapStation)
                .tag(station.identifier)
                
            }
        }
        .mapStyle(.standard)
        .mapControls {
            MapCompass()
            MapUserLocationButton()
        }
        .tint(.tflMapControl)
        .buttonBorderShape(.circle)
        .controlSize(.large)
        .safeAreaPadding([.top],100)
        .onChange(of:stationSelection.station) {
            guard let station = stationSelection.station else {
                return
            }
            
            withAnimation {
                let oldCoord = station.location.coordinate
                // Latitude 1 Degree : 111.111 KM = 1/1111 Degree ≈ 100 m
                let newCoord = CLLocationCoordinate2DMake( oldCoord.latitude - 1/1111, oldCoord.longitude )
                position = .item(MKMapItem(placemark: .init(coordinate: newCoord)))
                selection = station.identifier
            }
        }
        .onChange(of: selection) {
            guard let selection ,selection != stationSelection.station?.identifier else {
                return
            }
            
            let list = self.stationList.list
            guard let station = list.first(where:{ $0.identifier == selection }) else {
                return
            }
            stationSelection.station = station
        }
    }
}

#Preview {
    TFLMapBusStationView()
}
