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
    init(scene: Scene2D) {
        self.scene = scene
        _player = ObservedObject(initialValue: scene.player)
        _camera = ObservedObject(initialValue: scene.camera)
    }
    
    var body: some View {
        ZStack {
            TankView(tank: player)
                .readCenter()
                .position(screenPosition(worldPosition: player.position))
            EnemyArtilleryView()
                .position(screenPosition(worldPosition: scene.enemies[0].position))
        }
    }
    
    func screenPosition(worldPosition: SIMD2<Float>) -> CGPoint {
//        let transform = Matrix(
//            rows: [
//                SIMD3( 1,  0, worldPosition.x),
//                SIMD3( 0,  1, worldPosition.y),
//                SIMD3( 0,  0, 1)]
//        )
        
        
        let position = SIMD3<Float>(worldPosition, 1)
        let viewMatrix = scene.camera.transform.inverse
        let result = viewMatrix * position
        return CGPoint(x: Double(result.x), y: Double(result.y))
        
        
    }
    
    
}
