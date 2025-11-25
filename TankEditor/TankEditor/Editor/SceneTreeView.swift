//
//  ContentView.swift
//  Editor
//
//  Created by Sergey Kozlov on 17.11.2025.
//

import SwiftUI
import TankEngine2D

struct SceneTreeView: View {
    @StateObject var viewModel: SceneTreeViewModel
    var body: some View {
        List(viewModel.visibleNodes) { node in
            Text(node.displayName)
                .contextMenu {
                    Button("add rect") { viewModel.addRect() }

                }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

#Preview {
    SceneTreeView(viewModel:
                    SceneTreeViewModel(scene: ProjectContext.sampleContext.editorScene))
}
