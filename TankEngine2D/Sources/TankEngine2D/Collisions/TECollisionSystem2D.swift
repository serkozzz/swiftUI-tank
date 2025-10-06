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

//TODO optimization: collider should keep needUpdate flag that will be set after node movement;
//only needUpdate colliders should be checked with all other colliders
//after collisions check if there are not collisions TECollisionSystem2D resets needUpdate, else doesn't reset.
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
    
    
    func predictiveMove(sceneNode: TESceneNode2D, newPosition: SIMD2<Float>) -> [TECollider2D] {
        guard sceneNode.colliders.count != 0 else { return [] }    
        var intersectedColliders = [TECollider2D]()
        
        for collider in sceneNode.colliders {
            intersectedColliders += checkIntersections(collider: collider, with: colliders)
        }
        return intersectedColliders
    }
    
   
    

    func collisionSystemPass() {
        guard colliders.count > 1 else { return }
        
        for i in 0..<colliders.count {
            let collider1 = colliders[i]
            // Проверяем только с последующими, чтобы не было дублирования пар.
            let others = Array(colliders[(i+1)...])
            let intersected = checkIntersections(collider: collider1, with: others)
            for collider2 in intersected {
                print("collision: \(collider1.owner?.name ?? "?") x \(collider2.owner?.name ?? "?")")
                delegate?.teCollisionSystem2D(self, didDetectCollisionBetween: collider1, and: collider2)
            }
        }
    }
    
    func checkIntersections(collider: TECollider2D, with otherColliders: [TECollider2D]) -> [TECollider2D] {
        
        var intersectedColliders: [TECollider2D] = []
        
        let rect1 = TEAABB(center: collider.transform!.position, size: collider.boundingBox)
        
        for otherCollider in otherColliders {
            guard otherCollider !== collider else { continue }
            let rect2 = TEAABB(center: otherCollider.transform!.position, size: otherCollider.boundingBox)
            if rect1.intersects(rect2) {
                intersectedColliders.append(otherCollider)
            }
        }
        return intersectedColliders
    }

    
    // Если всё же хочется иметь «утилиту» внутри системы:
    // Короткая, читабельная сигнатура.
    func intersects(_ a: TEAABB, _ b: TEAABB) -> Bool {
        a.intersects(b)
    }
}

