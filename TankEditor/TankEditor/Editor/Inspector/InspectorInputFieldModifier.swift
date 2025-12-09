//
//  PropCell.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 04.12.2025.
//

import SwiftUI

struct InspectorInputFieldModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(Globals.INSPECTOR_PROPS_FONT)
            .textFieldStyle(.plain)
            .background(Color(nsColor: .controlBackgroundColor))
            .padding(.vertical, 2)
    }
}

extension View {
    func inspectorInputFieldModifier() -> some View {
        modifier(InspectorInputFieldModifier())
    }
}
