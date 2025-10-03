//
//  GameManager.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 01.10.2025.
//

import SwiftUI
import TankEngine2D

@MainActor
class GameManager: ObservableObject {
    
    let gameContext: GameContext
    let scene: TEScene2D
    
    private let damageSystem: DamageSystem
    
    init() {
        gameContext = GameContext()
        scene = gameContext.scene
        damageSystem = DamageSystem(scene: gameContext.scene)
        TETankEngine2D.shared.start(scene: gameContext.scene)
    }

    func spawnBullet(_ bullet: Bullet) {
        print("spawnBullet")
        scene.addSceneObject(bullet,
                             to: scene.rootNode,
                             position: bullet.startPosition,
                             boundingBox: bullet.size.cgSize,
                             view: AnyView(BulletView(bullet: bullet)))
        
        damageSystem.registerBullet(bullet)
    }
}

