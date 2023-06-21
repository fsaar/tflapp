//
//  Font.swift
//  tflapp
//
//  Created by Frank Saar on 20/06/2023.
//  Copyright © 2023 SAMedialabs. All rights reserved.
//


import Foundation
import SwiftUI

struct BoldFont: ViewModifier {
    var fontSize = CGFloat(12)
    func body(content: Content) -> some View {
        content
            .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/).font(.system(size: fontSize))
            
    }
}

struct RegularFont: ViewModifier {
    var fontSize = CGFloat(12)
    func body(content: Content) -> some View {
        content
            .font(.system(size: fontSize))
            
    }
}

extension View {
    func tflBoldFont(size : CGFloat) -> some View {
        var font = BoldFont()
        font.fontSize = size
        return  modifier(font)
    }
    func tflRegularFont(size : CGFloat) -> some View {
        var font = RegularFont()
        font.fontSize = size
        return  modifier(font)
    }
      
}
