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

struct TFLMapBusStationView : View {
    @Environment(\.stationList) var stationList : Binding<TFLStationList>
    @Environment(\.stationSelection) var stationSelection : Binding<TFLBusstationSelection>
    @State private var position : MapCameraPosition = .automatic
   
    @State private var selection : String?
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
            guard let station = stationSelection.wrappedValue.station, let mapPos = self.position else  {
                return
            }
//            let zoomScale = mapPos.camera.zoo
            let coord = station.location.coordinate
            withAnimation {
                position = .item(MKMapItem(placemark: .init(coordinate: coord)))
            }
        }
        .onChange(of: selection) {
            
            guard let selection else {
                return
            }
            let list = self.stationList.wrappedValue.list
            guard let station = list.filter({ $0.identifier == selection }).first else {
                return
            }
           
            stationSelection.station.wrappedValue = station
        }
    }
}

#Preview {
    TFLMapBusStationView()
}

