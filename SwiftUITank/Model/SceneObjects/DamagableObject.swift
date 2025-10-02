//
//  DamagableObject.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 01.10.2025.
//

class DamagableObject: BaseSceneObject {
    
    var health: Int
    
    init(health: Int) {
        self.health = health
    }

    func takeDamage() {
        health -= 1
        if health <= 0 {
            destroy()
        }
    }
    func destroy() {
        destroyed = true
    }
}
