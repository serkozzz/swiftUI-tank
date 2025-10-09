//
//  GameManager.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 01.10.2025.
//

import SwiftUI
import TankEngine2D

@MainActor
class GameLevelManager: ObservableObject {
    
    let levelContext: GameLevelContext
    
    private let scene: TEScene2D
    private let damageSystem: DamageSystem
    
    init(scene: TEScene2D) {
        let playerTank = PlayerTank()
        let playerMover = PlayerMover(playerTank, tankEngine2D: TETankEngine2D.shared)
        self.scene = scene
        self.scene.printGraph()
        scene.addPlayerTank(tankModel: playerTank)
        scene.addPlayerMover(playerMover)
        
        levelContext = GameLevelContext(scene: scene, playerTank: playerTank, playerMover: playerMover)
        damageSystem = DamageSystem(scene: scene)
        TETankEngine2D.shared.setScene(scene: scene)
        TETankEngine2D.shared.start()
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

