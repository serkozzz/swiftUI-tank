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
    @State var assembler: Assembler?
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                HStack {
                    SceneTreeView(viewModel: SceneTreeViewModel(scene: context.editorScene))
                    Scene2DView(scene: context.editorScene, onCompileTap: {
                        Task {
                            guard let assemblerResult = try? await assembler!.buildUserCode() else { return }
                            PluginLoader.shared.load(assemblerResult.dylibURL)
                        }
                    })
                    PropsInstectorView()
                }
                .frame(height: geo.size.height / 3 * 2)
                AssetsBrowserView(viewModel: AssetsBrowserViewModel(projectRoot: context.projectPath))
                    .frame(height: geo.size.height / 3)
            }
        }
        .onAppear() {
            assembler = Assembler(projectContext: context)
        }

    }
}

#Preview {
    EditorView()
        .environment(\.projectContext, ProjectContext.sampleContext)
}
