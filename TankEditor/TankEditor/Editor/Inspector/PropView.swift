//
//  PropView.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 04.12.2025.
//

import SwiftUI
import TankEngine2D

//factory of particular type representation views
struct PropView: View {
    @ObservedObject var viewModel: PropViewModel
    var body: some View {
        Text(viewModel.propName).propCell(alignment: .leading)
        switch (viewModel.propType) {
        case .bool:
            BoolRepresentation(value: viewModel.propBinding)
                .propCell(alignment: .trailing)
        case .number:
            Text(viewModel.codedValue).propCell(alignment: .trailing)
        case .string:
            Text(viewModel.codedValue).propCell(alignment: .trailing)
        case .other:
            Text(viewModel.codedValue).propCell(alignment: .trailing)
        }
    }
}
