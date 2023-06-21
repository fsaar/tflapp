//
//  View+Helper.swift
//

import Foundation
import SwiftUI
extension DynamicTypeSize {
    
}
struct HiddenAccessiblityLevelModfier : ViewModifier {
    @Environment(\.dynamicTypeSize) var dynamicTypeSize
    let level: DynamicTypeSize

    func body(content: Content) -> some View {
        let isHidden = dynamicTypeSize >= .accessibility1
        if !isHidden {
            content
        }
        
    }
        
}

struct HiddenModfier : ViewModifier {
    let isHidden : Bool
    func body(content: Content) -> some View {
        
        if !isHidden {
            content
        }
        
    }
        
}

struct BorderColorModifier<S:Shape> : ViewModifier {
    var shape : S?
    var color : Color = .white
    var lineWidth : CGFloat = 1
    func body(content: Content) -> some View {
        if let shape = shape {
            content.clipShape(shape).overlay {
                shape.stroke(color,lineWidth:lineWidth)
            }
        }
        else {
            content
        }
    }
}

extension View {
    func borderColor<S: Shape>(shape: S,color : Color,lineWidth: CGFloat = 1.0) -> some View {
        var borderColor = BorderColorModifier<S>()
        borderColor.shape = shape
        borderColor.color = color
        borderColor.lineWidth = lineWidth
        return modifier(borderColor)
    }
    
    func isHidden(_ isHidden: Bool) -> some View {
        let isHiddenModifier = HiddenModfier(isHidden: isHidden)
        return modifier(isHiddenModifier)
    }
    
    func isHiddenInAccessibilityLevels(from level: DynamicTypeSize) -> some View {
        let isHiddenModifier = HiddenAccessiblityLevelModfier(level: level)
        return modifier(isHiddenModifier)
    }
}
