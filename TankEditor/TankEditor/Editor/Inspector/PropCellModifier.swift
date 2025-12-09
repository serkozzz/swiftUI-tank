//
//  PropCell.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 04.12.2025.
//

import SwiftUI

struct PropCell: ViewModifier {
    let alignment: Alignment
    func body(content: Content) -> some View {
        content
            .font(Globals.INSPECTOR_PROPS_FONT)
            .padding(.horizontal, 6)
            .frame(maxWidth: .infinity, alignment: alignment)
            .frame(height: 16)
            .padding(.vertical, 2)
//            .background(
//                Rectangle()
//                    .stroke(Color.black)
//            )
    }
}

extension View {
    func propCell(alignment: Alignment) -> some View {
        modifier(PropCell(alignment: alignment))
    }
}
