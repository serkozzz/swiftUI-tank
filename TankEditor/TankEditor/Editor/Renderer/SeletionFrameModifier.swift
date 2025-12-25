//
//  SeletionFrameModifier.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 24.12.2025.
//

import SwiftUI

struct SeletionFrameModifier: ViewModifier {
    
    var isSelected: Bool
    @State private var flashColor: Color = .clear
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if isSelected {
                    Rectangle()
                        .stroke(flashColor, lineWidth: 1)
                        .allowsHitTesting(false)
                }
            }
            .onChange(of: isSelected) { newValue in
                if newValue {
                    flashColor = .blue
                    withAnimation(.easeOut(duration: 0.12)) {
                        flashColor = .white
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                        withAnimation(.easeIn(duration: 0.12)) {
                            flashColor = .blue
                        }
                    }
                } else {
                    flashColor = .clear
                }
            }
            .onAppear {
                flashColor = isSelected ? .blue : .clear
            }
    }
}

extension View {
    func selectionFrame(isSelected: Bool) -> some View {
        modifier(SeletionFrameModifier(isSelected: isSelected))
    }
}
