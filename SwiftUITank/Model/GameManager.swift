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
    
    private let damageSystem: DamageSystem
    
    init() {
        gameContext = GameContext()
        damageSystem = DamageSystem(scene: gameContext.scene)
        TETankEngine2D.shared.start(scene: gameContext.scene)
    }

    func spawnBullet(_ bullet: Bullet) {
        print("spawnBullet")
        gameContext.scene.addSceneObject(bullet, position: bullet.startPosition, boundingBox: bullet.size.cgSize, view: AnyView(BulletView(bullet: bullet)))
        damageSystem.registerBullet(bullet)
    }
}
