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
        _camera = ObservedObject(initialValue: scene.camera)
    }
    
    public var body: some View {
        print ("TESceneRender2D body")
        return GeometryReader { geo in
            ZStack {
                if (TESettings2D.SHOW_SCENE_BOUNDS) {
                    let sceneCenter = SIMD2<Float>(Float(scene.sceneBounds.midX), Float(scene.sceneBounds.midY))
                    let sceneCenterTransform = TETransform2D(position: sceneCenter)
                    let transform = camera.worldToScreen(objectWorldTransform: sceneCenterTransform)
                    let sceneCenterOnScreen = transform.matrix * SIMD3<Float>(sceneCenter, 1)
                    Rectangle().fill(.green)
                        .frame(width: scene.sceneBounds.width, height: scene.sceneBounds.height)
                        .rotationEffect(transform.rotation)
                        .position(transform.position.cgPoint())
                        
                }
                NodeView(node: scene.rootNode, camera: scene.camera)
            }
            .scaleEffect(x: 1, y: -1, anchor: .topLeading)
            .offset(y: geo.size.height)
            .onAppear {
                camera.viewportSize = geo.size
            }
            .onChange(of: geo.size) { newSize in
                camera.viewportSize = newSize
            }
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
            if let geometryObj = node.geometryObject {
                geometryObj.viewToRender
                    .frame(width: geometryObj.boundingBox.width,
                           height: geometryObj.boundingBox.height)
                    .rotationEffect(transform.rotation)
                    .position(transform.position.cgPoint())
                
            }
            if TESettings2D.SHOW_COLLIDERS, let collider = node.collider {
                if collider.shape == .geometry,
                   let geometryObj = node.geometryObject {
                    TEColliderView2D()
                        .frame(width: geometryObj.boundingBox.width,
                               height: geometryObj.boundingBox.height)
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
