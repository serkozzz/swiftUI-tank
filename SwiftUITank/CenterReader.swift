//
//  ReadGlobalCoords.swift
//  sandbox
//
//  Created by Sergey Kozlov on 01.09.2025.
//

import SwiftUI


struct CenterPreferenceKey:  PreferenceKey {
     
    nonisolated(unsafe) static var defaultValue: CGPoint = .zero
    
    static func reduce(value: inout CGPoint, nextValue: () -> CGPoint) {
        value = nextValue()
    }
}

struct CenterReader: ViewModifier {
    func body(content: Content) -> some View {
        content.background(
            GeometryReader { geo in
                Color.clear.preference(
                    key: CenterPreferenceKey.self,
                    value: CGPoint(x: geo.frame(in: .global).midX,
                                   y: geo.frame(in: .global).midY)
                )
            }
        )
    }
}

extension View {
    func readCenter() -> some View {
        self.modifier(CenterReader())
    }
}
