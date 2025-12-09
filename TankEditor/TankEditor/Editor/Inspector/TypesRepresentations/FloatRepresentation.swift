//
//  NumberRepresentation.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 03.12.2025.
//

import SwiftUI

struct FloatRepresentaton : View {
    @Binding var value: Float
    var body: some View {
        TextField("", text: Binding(get: {
            String(value)
        }, set: { newValue in
            guard let newFloat = Float(newValue) else { return }
            value = newFloat
        }))
        .inspectorInputFieldModifier()
    }
}
