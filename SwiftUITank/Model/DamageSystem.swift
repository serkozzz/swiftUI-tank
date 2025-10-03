//
//  DamageSystem.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 01.10.2025.
//

import TankEngine2D

@MainActor
class DamageSystem {
    
    private let scene: TEScene2D
    
    init(scene: TEScene2D) {
        self.scene = scene
    }
    
    func registerBullet(_ bullet: Bullet) {
        bullet.onCollision = { [weak self] bullet, geometryObject in
            guard let self else { return }
            bullet.destroy()
            bullet.removeFromScene()
        
            
            guard let damagableObject = geometryObject.owner!.getComponents(DamagableObject.self).first else { return }
            damagableObject.takeDamage()
            if damagableObject.health <= 0 {
                damagableObject.destroy {
                    damagableObject.removeFromScene()
                }
            }
            
        }
    }
}
