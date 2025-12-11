//
//  ComponentRefRepresentation.swift
//  TankEditor
//
//  Created by Sergey Kozlov on 10.12.2025.
//

import SwiftUI
import TankEngine2D
import UniformTypeIdentifiers

struct ComponentRefRepresentation : View {
    @ObservedObject var viewModel: ComponentRefViewModel
    
    var body: some View {
        Text(viewModel.valueToShow)
            .frame(maxWidth: .infinity)
            .background {
                if viewModel.isUnderAcceptableDrag { Rectangle().stroke(Color.accentColor) } else { Color.clear }
            }
            .onDrop(of: [SceneNodeDragManager.shared.utType],
                    delegate: {
                print(".onDrop")
                return viewModel
            }())
            
    }
}

