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
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .frame(maxWidth: .infinity, alignment: alignment)
            .background(
                Rectangle()
                    .stroke(Color.black)
            )
    }
}

extension View {
    func propCell(alignment: Alignment) -> some View {
        modifier(PropCell(alignment: alignment))
    }
}
