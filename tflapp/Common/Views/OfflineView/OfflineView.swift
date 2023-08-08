//
//  OfflineView.swift
//  tflapp
//
//  Created by Frank Saar on 08/08/2023.
//  Copyright © 2023 SAMedialabs. All rights reserved.
//

import Foundation
import SwiftUI

struct OfflineView : View {
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Image(systemName:"antenna.radiowaves.left.and.right.slash")
                    .font(.title)
                  
                Text("TFLOfflineView.offline.title")
                    .font(.title)
                    
                Spacer()
                   
            }.padding([.horizontal,.vertical],10)
             
                .foregroundColor(.tflOfflineViewText)
               
        }
        .overlay {
            Capsule().stroke(.tflOfflineViewBackground,lineWidth:2)
        }.background(.regularMaterial)
            .clipShape( Capsule())
           
    }
}
