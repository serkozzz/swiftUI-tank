//
//  BoolRepresentaton.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 03.12.2025.
//

import SwiftUI

struct BoolRepresentation: View {
    @Binding var value: Bool

    var body: some View {
        Toggle("", isOn: $value)
    }
}

#Preview {
    @Previewable @State var isOn: Bool = false
    BoolRepresentation(value: $isOn) 
        .frame(width: 300, height: 300)
}
