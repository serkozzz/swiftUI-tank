//
//  Renderer.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 20.09.2025.
//

import SwiftUI
import simd

public struct SceneRender : View {
    
    private let scene: TEScene2D
    @ObservedObject private var camera: TECamera2D
    public init(scene: TEScene2D) {
        self.scene = scene
        _camera = ObservedObject(initialValue: scene.camera)
    }
    
    public var body: some View {
        GeometryReader { geo in
            ZStack {
                ForEach(scene.nodes) { node in
                    if let geometryObj = node.geometryObject {
                        geometryObj.viewToRender
                            .frame(width: geometryObj.boundingBox.width,
                                   height: geometryObj.boundingBox.height)
                            .position(screenPosition(worldPosition: node.transform.position))
                        
                    }
                }
            }
            .scaleEffect(x: 1, y: -1, anchor: .topLeading)
            .offset(y: geo.size.height)
        }
    }
    
    private func screenPosition(worldPosition: SIMD2<Float>) -> CGPoint {
        let screenPos = camera.worldToScreen(worldPosition: worldPosition)
        return CGPoint(x: Double(screenPos.x), y: Double(screenPos.y))
    }
}
