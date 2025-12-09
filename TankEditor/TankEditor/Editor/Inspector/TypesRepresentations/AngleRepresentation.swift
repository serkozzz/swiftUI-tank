//
//  NumberRepresentation.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 03.12.2025.
//

import SwiftUI

struct AngleRepresentation : View {
    @Binding var value: Angle
    var body: some View {
        TextField("", text: Binding(get: {
            String(value.degrees)
        }, set: { newValue in
            guard let newDouble = Double(newValue) else { return }
            let angle = Angle(degrees: newDouble)
            value = angle
        }))
        .inspectorInputFieldModifier()
    }
}
