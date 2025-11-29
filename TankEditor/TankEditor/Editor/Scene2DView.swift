//
//  ContentView.swift
//  Editor
//
//  Created by Sergey Kozlov on 17.11.2025.
//

import SwiftUI
import TankEngine2D

struct Scene2DView: View {
    //@StateObject var vm = GameViewModel()
    @ObservedObject var scene: TEScene2D
    
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
            viewType: TERectangleView2D.self,
            viewModelType: TERectangle2D.self
        )
        s.rootNode.addChild(node)
        self.scene = s
    }

    var body: some View {
        Scene2DView(scene: scene)
    }
}
