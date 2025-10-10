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
        GeometryReader { geo in
            ZStack {
                Rectangle().fill(.green)
                    .frame(width: scene.sceneBounds.width, height: scene.sceneBounds.height)
                    .position(worldToScreen(scene.sceneBounds.midX, scene.sceneBounds.midY))
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
    
    private func worldToScreen(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        camera.worldToScreen(worldPosition: SIMD2<Float>(Float(x), Float(y)))
    }
}

struct NodeView: View {
    @ObservedObject var node: TESceneNode2D
    @ObservedObject var camera: TECamera2D
    
    var body: some View {
        if let geometryObj = node.geometryObject {
            geometryObj.viewToRender
                .frame(width: geometryObj.boundingBox.width,
                       height: geometryObj.boundingBox.height)
                .position(worldToScreen(node.transform.position))
            
        }
        ForEach(node.children) { child in
            NodeView(node: child, camera: camera)
        }
    }
    
    private func worldToScreen(_ worldPosition: SIMD2<Float>) -> CGPoint {
        camera.worldToScreen(worldPosition: worldPosition)
    }
}
