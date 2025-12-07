//
//  NumberRepresentation.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 03.12.2025.
//

import SwiftUI

struct Vector2Representaton : View {
    @Binding var value: SIMD2<Float>
    
    var body: some View {
        HStack {
            TextField("", text: Binding(get: {
                String(value.x)
            }, set: { newValue in
                guard let x = Float(newValue) else { return }
                    value.x = x
            }))
            TextField("", text: Binding(get: {
                String(value.y)
            }, set: { newValue in
                guard let y = Float(newValue) else { return }
                    value.y = y
            }))
        }
    }
}
