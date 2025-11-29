//
//  ContentView.swift
//  Editor
//
//  Created by Sergey Kozlov on 17.11.2025.
//

import SwiftUI
import TankEngine2D

struct StarterView: View {
    private let defaultPath = "/Users/sergeykozlov/Documents/TankEngineProjects/Sandbox"
    @State private var projectContext: ProjectContext?
    @State var isOpened = false
    var body: some View {
        if (isOpened) {
            EditorView()
                .environment(\.projectContext, projectContext)
        }
        else {
            Button("open") {
                isOpened = true
                
                let _ = TETankEngine2D.shared //for init
                let sceneBounds = CGRect(origin: CGPoint(x: -500, y: -500), size: CGSize(width: 1000, height: 1000))
                let scene = TEScene2D(sceneBounds: sceneBounds)
//                let node = TESceneNode2D(position: .zero, viewType: TERectangleView2D.self, viewModelType: TERectangle2D.self)
//                scene.rootNode.addChild(node)
                projectContext = ProjectContext(scene: scene, projectPath: defaultPath)
            }
        }
    }
}

#Preview {
    StarterView()
}
