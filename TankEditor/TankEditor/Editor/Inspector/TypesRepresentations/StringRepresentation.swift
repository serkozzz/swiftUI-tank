//
//  StringRepresentation.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 03.12.2025.
//

import SwiftUI

struct StringRepresentaton : View {
    @Binding var value: String
    var body: some View {
        TextField("", text: $value)
            .inspectorInputFieldModifier()
    }
}
