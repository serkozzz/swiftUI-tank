//
//  ContentView.swift
//  Editor
//
//  Created by Sergey Kozlov on 17.11.2025.
//

import SwiftUI
import TankEngine2D

struct PropsInspectorView: View {
    @ObservedObject var viewModel: PropsInspectorViewModel
    
    var body: some View {
        if viewModel.selectedNode == nil {
            Color.clear
        } else {
            var node = viewModel.selectedNode!
            VStack {
                Text("NodeName: \(node.displayName)")
                Text("Views:")
                List {
                    ForEach(node.views, id: \.id) { view in
                        Text(String(describing: type(of: view)))
                    }
                }
                Text("Components:")
                List {
                    ForEach(node.components) { component in
                        Text(String(describing: type(of: component)))
                    }
                }
            }
        }
    }
}

#Preview {
    PropsInspectorView(viewModel: PropsInspectorViewModel(projectContext: ProjectContext.sampleContext))
}
