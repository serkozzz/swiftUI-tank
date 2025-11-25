//
//  ContentView.swift
//  Editor
//
//  Created by Sergey Kozlov on 17.11.2025.
//

import SwiftUI
import TankEngine2D

struct EditorView: View {
    @Environment(\.projectContext) private var context: ProjectContext!
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                HStack {
                    SceneTreeView(viewModel: SceneTreeViewModel(scene: context.editorScene))
                    //Scene2DView()
                    PropsInstectorView()
                }
                .frame(height: geo.size.height / 3 * 2)
                AssetsBrowserView(viewModel: AssetsBrowserViewModel(projectRoot: context.projectPath))
                    .frame(height: geo.size.height / 3)
            }
        }

    }
}

#Preview {
    EditorView()
        .environment(\.projectContext, ProjectContext.sampleContext)
}
