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
    @ObservedObject var viewModel: SceneRendererViewModel
    
    @State var nodePosWhenDragStarted: SIMD2<Float>?
    @State private var position: CGPoint = .zero
    
    var onCompileTap: (() -> Void)?
    var body: some View {
        ZStack(alignment: .top) {
            
            TESceneRender2D(scene: scene, nodeModifier: { node, camera, nodeView in
                AnyView(nodeView
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if nodePosWhenDragStarted == nil {
                                    nodePosWhenDragStarted = node.transform.position
                                }
                                let translation = SIMD2<Float>( x: Float(value.translation.width),
                                                                y: Float(value.translation.height))
                                print ("drag. \(node.displayName) translation: \(translation)")
                                node.transform.setPosition(nodePosWhenDragStarted! + translation)
                            }
                            .onEnded { value in
                                nodePosWhenDragStarted = nil
                            }
                    )
                        .onTapGesture {
                            viewModel.select(node: node)
                        }
                )
            })
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
        SceneRendererView(scene: scene, viewModel: SceneRendererViewModel(projectContext: .sampleContext, delegate: nil))
    }
}
