//
//  Renderer.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 20.09.2025.
//

import SwiftUI
import simd

struct SceneRender : View {
    
    let scene: Scene2D
    @ObservedObject private var player: PlayerTank
    @ObservedObject private var camera: Camera
    init(scene: Scene2D, player: PlayerTank) {
        self.scene = scene
        _player = ObservedObject(initialValue: player)
        _camera = ObservedObject(initialValue: scene.camera)
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                TankView(tank: player)
                    .position(screenPosition(worldPosition: player.transform!.position))
                ForEach(scene.nodes) { node in
                    if let geometryObj = node.geometryObject {
                        GeometryObjectViewsFactory.getView(for: geometryObj.type)
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
    
    func screenPosition(worldPosition: SIMD2<Float>) -> CGPoint {
        let screenPos = camera.worldToScreen(worldPosition: worldPosition)
        return CGPoint(x: Double(screenPos.x), y: Double(screenPos.y))
    }
}



#Preview {
    SceneRender(scene: GameModel().scene, player: PlayerTank())
}
