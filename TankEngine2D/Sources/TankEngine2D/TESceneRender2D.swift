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
    
    var body: some View {
        print("NodeView body")
        return Group {
            let transform = camera.worldToScreen(objectWorldTransform: node.worldTransform)
    
            ForEach(node.visualComponents, id: \.id) { visualComp in
                let size = (visualComp as! TEComponent2D).size
                visualComp.createView()
                    .frame(width: size.width,
                           height: size.height)
                    .rotationEffect(transform.rotation)
                    .position(transform.position.cgPoint())
            }

            if TESettings2D.SHOW_COLLIDERS, let collider = node.collider {
                if collider.shape == .geometry,
                   let nodeView = node.visualComponents.first as? TEComponent2D {
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
