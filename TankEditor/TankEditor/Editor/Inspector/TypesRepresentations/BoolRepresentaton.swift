//
//  BoolRepresentaton.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 03.12.2025.
//

import SwiftUI

struct BoolRepresentaton: View {
    @State var value: Bool

    var body: some View {
        Toggle("", isOn: $value)
            .onChange(of: value) {
            }
    }
}

#Preview {
    @Previewable @State var isOn: Bool = false
    BoolRepresentaton(value: isOn).frame(width: 300, height: 300)
}
