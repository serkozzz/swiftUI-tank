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
            ZStack(alignment: .leading) {
                NodeView(node: node, viewModel: viewModel)
            }
            .listRowInsets(EdgeInsets()) //чтобы фон подсветки занимал всю ширину строки
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}


private struct NodeView: View {
    let node: TESceneNode2D
    @ObservedObject var viewModel: SceneTreeViewModel
    @State private var isTargeted: Bool = false

    var body: some View {
        Text(node.displayName)
            .padding(.horizontal, 8) // чтобы фон подсветки был заметнее
            .background(isTargeted ? Color.accentColor.opacity(0.15) : Color.clear)
            .contextMenu {
                Button("add rect") { viewModel.addRect() }
                Button("add empty node") { viewModel.addEmptyNode() }
            }
            .dropDestination(for: Asset.self, action: { assets, _ in
                let accepted = assets.filter { $0.type == .file }
                guard !accepted.isEmpty else { return false }
                for asset in accepted {
                    viewModel.handleDrop(asset: asset, to: node)
                }
                return true
            }, isTargeted: { hovering in
                isTargeted = hovering
            })
    }
}

#Preview {
    SceneTreeView(viewModel:
                    SceneTreeViewModel(scene: ProjectContext.sampleContext.editorScene))
}
