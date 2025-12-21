//
//  Renderer.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 20.09.2025.
//

import SwiftUI
import simd

public struct TESceneRender2D : View {
    
    @ObservedObject private var scene: TEScene2D
    @ObservedObject private var camera: TECamera2D
    
    public init(scene: TEScene2D) {
        self.scene = scene
        self.camera = scene.camera
    }
    
    public var body: some View {
        print ("TESceneRender2D body")
        return GeometryReader { geo in
            ZStack {
                if (TESettings2D.SHOW_SCENE_BOUNDS) {
                    let sceneCenter = SIMD2<Float>(Float(scene.sceneBounds.midX), Float(scene.sceneBounds.midY))
                    let sceneCenterTransform = TETransform2D(position: sceneCenter)
                    let transform = camera.worldToScreen(objectWorldTransform: sceneCenterTransform)
                    Rectangle().fill(.green)
                        .frame(width: scene.sceneBounds.width, height: scene.sceneBounds.height)
                        .rotationEffect(transform.rotation)
                        .position(transform.position.cgPoint())
                        
                }
                
                NodeView(node: scene.rootNode, camera: camera)
            }
            .scaleEffect(x: 1, y: -1, anchor: .topLeading)
            .offset(y: geo.size.height)
            .onAppear {
                camera.viewportSize = geo.size
            }
            .onChange(of: geo.size) { newSize in
                camera.viewportSize = newSize
            }
            .onChange(of: scene) { newScene in
                newScene.camera.viewportSize = geo.size
            }
            .clipped()
        }
    }
}

struct NodeView: View {
    @ObservedObject var node: TESceneNode2D
    @ObservedObject var camera: TECamera2D
    
    @State var nodePosWhenDragStarted: SIMD2<Float>?
    @State private var position: CGPoint = .zero

    
    var body: some View {
        print("NodeView body")
        return Group {
            let transform = camera.worldToScreen(objectWorldTransform: node.worldTransform)
    
            ForEach(node.visualComponents, id: \.id) { visualComp in
                visualComp.createView()
                    .frame(width: visualComp.size.width,
                           height: visualComp.size.height)
                    .rotationEffect(transform.rotation)
                    .position(transform.position.cgPoint())
                    .zIndex(Double(visualComp.zIndex))
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
            }

            if TESettings2D.SHOW_COLLIDERS, let collider = node.collider {
                if collider.shape == .geometry,
                   let nodeView = node.visualComponents.first {
                    TEColliderView2D(viewModel: collider)
                        .frame(width: nodeView.size.width,
                               height: nodeView.size.height)
                        .rotationEffect(transform.rotation)
                        .position(transform.position.cgPoint())
                }
            }
            ForEach(node.children) { child in
                NodeView(node: child, camera: camera)
            }
        }
    }
}
