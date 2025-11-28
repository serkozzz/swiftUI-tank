//
//  DamageSystem.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 01.10.2025.
//

import Foundation

@MainActor
class DamageSystem {
    
    private let scene: TEScene2D
    
    init(scene: TEScene2D) {
        self.scene = scene
    }
    
    func registerBullet(_ bullet: Bullet) {
        bullet.onCollision = { bullet, collider in
            guard bullet.spawner.owner != collider.owner else { return }
            
            bullet.destroy()
            bullet.removeFromScene()
        
            
            guard let damagableObject = collider.owner!.getComponents(DamagableObject.self).first else { return }
            damagableObject.takeDamage()
            if damagableObject.health <= 0 {
                damagableObject.destroy {
                    damagableObject.removeFromScene()
                }
            }
            
        }
    }
}
