//
//  NumberRepresentation.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 03.12.2025.
//

import SwiftUI

struct IntegerRepresentaton : View {
    @Binding var value: Int
    var body: some View {
        TextField("", text: Binding(get: {
            String(value)
        }, set: { newValue in
            guard let integer = Int(newValue) else { return }
            value = integer
        }))
    }
}
