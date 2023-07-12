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
    @Environment(\.stationList) var stationList : Binding<TFLStationList>
    @Environment(\.stationSelection) var stationSelection : Binding<TFLBusstationSelection>
    @State private var position : MapCameraPosition = .automatic
    @State private var selection : String?
    fileprivate let logger : Logger =  {
        let handle = Logger(subsystem: TFLLogger.subsystem, category: TFLLogger.category.map.rawValue)
        return handle
    }()
    var body : some View {
        Map(position:$position, selection:$selection) {
            ForEach(stationList.list) { station in
                Marker(station.wrappedValue.name,
                       systemImage: "bus.doubledecker.fill",
                       coordinate:  station.wrappedValue.location.coordinate)
                .tint(.tflMapStation)
                .tag(station.wrappedValue.identifier)
                
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
        .onChange(of:stationSelection.wrappedValue.station) {
            guard let station = stationSelection.wrappedValue.station else {
                return
            }
            
            withAnimation {
                position = .item(MKMapItem(placemark: .init(coordinate: station.location.coordinate)))
                selection = station.identifier
            }
        }
        .onChange(of: selection) {
            guard let selection ,selection != stationSelection.wrappedValue.station?.identifier else {
                return
            }
            
            let list = self.stationList.wrappedValue.list
            guard let station = list.first(where:{ $0.identifier == selection }) else {
                return
            }
            stationSelection.station.wrappedValue = station
        }
    }
}

#Preview {
    TFLMapBusStationView()
}

