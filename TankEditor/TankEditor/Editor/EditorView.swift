//
//  ContentView.swift
//  Editor
//
//  Created by Sergey Kozlov on 17.11.2025.
//

import SwiftUI
import TankEngine2D

struct EditorView: View {
    @Environment(\.projectPath) private var projectPath: String
    
    var body: some View {
        VStack() {
            HStack {
                SceneTreeView()
                //Scene2DView()
                PropsInstectorView()
            }
            AssetsBrowserView(viewModel: AssetsBrowserViewModel(projectRoot: projectPath))
        }

    }
}

#Preview {
    EditorView()
        .environment(\.projectPath, "/Users/sergeykozlov/Documents/TankEngineProjects/Sandbox")
}
