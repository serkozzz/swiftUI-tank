//
//  TransformRepresentation.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 07.12.2025.
//

import SwiftUI

struct TransformRepresentation: View {
    @ObservedObject var viewModel: TransfromRepresentationViewModel

    var body: some View {
        VStack {
            HStack(spacing: 0) {
                Text("position").propCell(alignment: .leading)
                Vector2Representaton(value: viewModel.positionBinding).propCell(alignment: .trailing)
            }
            HStack(spacing: 0) {
                Text("rotation").propCell(alignment: .leading)
                AngleRepresentation(value: viewModel.rotationBinding).propCell(alignment: .trailing)
            }
            HStack(spacing: 0) {
                Text("scale").propCell(alignment: .leading)
                Vector2Representaton(value: viewModel.scaleBinding).propCell(alignment: .trailing)
            }
        }
    }
}
