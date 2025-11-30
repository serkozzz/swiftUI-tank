//
//  ContentView.swift
//  Editor
//
//  Created by Sergey Kozlov on 17.11.2025.
//

import SwiftUI
import TankEngine2D

struct EditorView: View {
    private var context: ProjectContext!
    @State var assembler: Assembler?
    @ObservedObject private var editorViewModel: EditorViewModel
    
    init(context: ProjectContext) {
        self.context = context
        editorViewModel =  EditorViewModel(projectContext: context)
    }
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                HStack {
                    SceneTreeView(viewModel: editorViewModel.treeVM)
                    SceneRendererView(scene: context.editorScene,
                                      viewModel: editorViewModel.sceneRenderViewModel,
                                      onCompileTap: {
                        Task {
                            guard let assemblerResult = try? await assembler!.buildUserCode() else { return }
                            PluginLoader.shared.load(assemblerResult.dylibURL)
                        }
                    })
                    PropsInspectorView(viewModel: editorViewModel.propsInspectorVM)
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
    @Previewable @State var context = ProjectContext.sampleContext
    EditorView(context: context)
        .environment(\.projectContext, context )
}
