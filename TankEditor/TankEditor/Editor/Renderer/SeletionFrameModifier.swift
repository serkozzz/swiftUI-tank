//
//  SeletionFrameModifier.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 24.12.2025.
//

import SwiftUI

struct SeletionFrameModifier: ViewModifier {
    
    var isSelected: Bool
    
    func body(content: Content) -> some View {
        if isSelected {
            content
                .overlay {
                    Rectangle()
                        .stroke(Color.blue, lineWidth: 1)
                        .allowsHitTesting(false)
                }
        } else {
            content
        }
    }
}

extension View {
    func selectionFrame(isSelected: Bool) -> some View {
        modifier(SeletionFrameModifier(isSelected: isSelected))
    }
}
