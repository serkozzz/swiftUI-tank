//
//  ContentView.swift
//  Editor
//
//  Created by Sergey Kozlov on 17.11.2025.
//

import SwiftUI
import AppKit
import TankEngine2D




struct PropsInspectorView: View {
    @ObservedObject var viewModel: PropsInspectorViewModel
    
    var body: some View {
        ZStack {
            Color(nsColor: .controlBackgroundColor)
            if let node = viewModel.selectedNode {
                ScrollView {
                    VStack {
                        Text("NodeName: \(node.displayName)").font(Globals.INSPECTOR_SUBHEADER_FONT)
                        
                        transformSection()
                        
                        Divider()
                        ComponentsCollectionView(viewModel: viewModel,
                                                 components: node.components)
                    }
                    
                    .padding()
                }
            }
        }
    }
    
    @ViewBuilder func transformSection() -> some View {
        VStack(alignment: .leading) {
            Text("Transform:").font(Globals.INSPECTOR_SUBHEADER_FONT).padding(.leading, 8)
            VStack(alignment: .leading) {
                HStack(spacing: 0) {
                    TransformRepresentation(viewModel: .init(node: viewModel.selectedNode!))
                }
            }
            .background(
                Rectangle()
                    .stroke(Color.black))
        }
    }
}



#Preview {
    @Previewable @State var vm =  PropsInspectorViewModel(projectContext: ProjectContext.sampleContext, selectedNode: nil)
    vm.selectedNode = vm.projectContext.editorScene.rootNode.children[1]
    return PropsInspectorView(viewModel: vm).frame(width: 300, height: 600)
}
