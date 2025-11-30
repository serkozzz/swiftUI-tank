//
//  ContentView.swift
//  Editor
//
//  Created by Sergey Kozlov on 17.11.2025.
//

import SwiftUI
import TankEngine2D

struct SceneTreeView: View {
    @ObservedObject var viewModel: SceneTreeViewModel
    
    var body: some View {
        List(viewModel.visibleNodes) { node in
            ZStack(alignment: .leading) {
                NodeView(node: node, treeViewModel: viewModel)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}


private struct NodeView: View {
    let node: TESceneNode2D
    @ObservedObject var treeViewModel: SceneTreeViewModel
    @State private var isTargeted: Bool = false
    
    var isSelected: Bool { treeViewModel.selectedNode?.id == node.id }

    var body: some View {
        Text(node.displayName)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 8) // чтобы фон подсветки был заметнее
            .background(isTargeted || isSelected ? Color.accentColor.opacity(0.15) : Color.clear)
            .contextMenu {
                Button("add rect") { treeViewModel.addRect() }
                Button("add empty node") { treeViewModel.addEmptyNode() }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                treeViewModel.select(node: node)
            }
            .dropDestination(for: Asset.self, action: { assets, _ in
                let accepted = assets.filter { $0.type == .file }
                guard !accepted.isEmpty else { return false }
                for asset in accepted {
                    treeViewModel.handleDrop(asset: asset, to: node)
                    treeViewModel.select(node: node)
                }
                return true
            }, isTargeted: { hovering in
                isTargeted = hovering
            })
    }
}

#Preview {
    SceneTreeView(viewModel:
                    SceneTreeViewModel(scene: ProjectContext.sampleContext.editorScene, delegate: nil))
}
