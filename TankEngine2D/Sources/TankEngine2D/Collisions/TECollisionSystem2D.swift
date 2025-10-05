//
//  TECollisionSystem2D.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 05.10.2025.
//

import CoreGraphics
import simd

@MainActor
protocol TECollisionSystem2DDelegate: AnyObject {
    func teCollisionSystem2D(_ collisionSystem: TECollisionSystem2D, didDetectCollisionBetween collider1: TECollider2D, and collider2: TECollider2D)
}


@MainActor
class TECollisionSystem2D {
    
    weak var delegate: TECollisionSystem2DDelegate?
    private var colliders: [TECollider2D] = []
    
    func register(collider: TECollider2D) {
        // Не допускаем повторной регистрации одного и того же инстанса
        guard !colliders.contains(where: { $0 === collider }) else { return }
        colliders.append(collider)
    }
    
    func unregister(collider: TECollider2D) {
        colliders.removeAll(where: { $0 === collider })
    }
    
    func checkCollisions() {
        for i in 0..<colliders.count {
            for j in (i+1)..<colliders.count {
                let c1 = colliders[i]
                let c2 = colliders[j]
                
                
                guard
                    let go1 = c1.owner?.geometryObject,
                    let go2 = c2.owner?.geometryObject
                else { continue }
                
                let rect1 = TEAABB(center: c1.transform!.position, size: go1.boundingBox)
                let rect2 = TEAABB(center: c2.transform!.position, size: go2.boundingBox)
                
                
                if rect1.intersects(rect2) {
                    print("collision: \(c1.owner!.name) x \(c2.owner!.name)")
                    delegate?.teCollisionSystem2D(self, didDetectCollisionBetween: c1, and: c2)
                }
            }
        }
    }
    
    // Если всё же хочется иметь «утилиту» внутри системы:
    // Короткая, читабельная сигнатура.
    func intersects(_ a: TEAABB, _ b: TEAABB) -> Bool {
        a.intersects(b)
    }
}
