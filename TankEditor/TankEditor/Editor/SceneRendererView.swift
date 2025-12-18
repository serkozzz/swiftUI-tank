//
//  ContentView.swift
//  Editor
//
//  Created by Sergey Kozlov on 17.11.2025.
//

import SwiftUI
import TankEngine2D

struct SceneRendererView: View {
    
    @ObservedObject var scene: TEScene2D
    var viewModel: SceneRendererViewModel
    
    var onCompileTap: (() -> Void)?
    var body: some View {
        ZStack(alignment: .top) {
            
            TESceneRender2D(scene: scene)
                .overlay {
                    Rectangle().stroke(.black)
                }
            HStack {
                Spacer()
                HStack {
                    Spacer()
                    Button("Compile") {
                        onCompileTap?()
                    }
                    Button("Save") {
                        //vm.saveScene()
                    }
                    .background(.yellow)
                    Button("Load") {
                        //vm.loadScene()
                    }
                    .background(.yellow)
                }
            }
        }
    }
    
}

#Preview {
    PreviewScene2DContainer()
}

private struct PreviewScene2DContainer: View {
    private let scene: TEScene2D

    init() {
        let s = TEScene2D(sceneBounds: CGRect(x: -1000, y: -1000, width: 2000, height: 2000))
        let node = TESceneNode2D(
            position: .zero,
            componentType: TERectangle2D.self
        )
        s.rootNode.addChild(node)
        self.scene = s
    }

    var body: some View {
        SceneRendererView(scene: scene, viewModel: SceneRendererViewModel(projectContext: .sampleContext))
    }
}
