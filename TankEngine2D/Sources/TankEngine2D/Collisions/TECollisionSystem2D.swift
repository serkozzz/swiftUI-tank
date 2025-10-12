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
        guard !colliders.contains(where: { $0 === collider }) else { return }
        colliders.append(collider)
    }
    
    func unregister(collider: TECollider2D) {
        colliders.removeAll(where: { $0 === collider })
    }
    
    func reset() {
        colliders.removeAll()
    }

    
    /// Проверяет все пары коллайдеров на столкновение.
    func collisionSystemPass() {
        guard !TESettings2D.DISABLE_COLLISIONS else { return }
        guard colliders.count > 1 else { return }
        let snapshot = colliders
        for i in 0..<snapshot.count {
            let collider1 = snapshot[i]
            let others = Array(snapshot[(i+1)...])
            let intersected = checkIntersections(collider: collider1, with: others)
            for collider2 in intersected {
                print("collisionSystemPass: collision: \(collider1.owner?.name ?? "?") x \(collider2.owner?.name ?? "?")")
                delegate?.teCollisionSystem2D(self, didDetectCollisionBetween: collider1, and: collider2)
            }
        }
    }
    
    /// Универсальная функция: возвращает все коллайдеры из otherColliders, чьи OBB пересекаются с obb1.
    /// Можно передать excludedCollider, чтобы не сравнивать с самим собой.
    func checkIntersections(obb1: TEOBB, excluding excludedCollider: TECollider2D? = nil, with otherColliders: [TECollider2D]) -> [TECollider2D] {
        var intersectedColliders: [TECollider2D] = []
        for otherCollider in otherColliders {
            if otherCollider === excludedCollider { continue }
            guard let otherWT = otherCollider.worldTransform else { continue }
            let obb2 = TEOBB(worldTransform: otherWT, size: otherCollider.boundingBox)
            if obb1.intersects(obb2) {
                intersectedColliders.append(otherCollider)
            }
        }
        return intersectedColliders
    }
    
    /// Удобная обёртка: принимает коллайдер, строит для него OBB и вызывает универсальную функцию.
    func checkIntersections(collider: TECollider2D, with otherColliders: [TECollider2D]) -> [TECollider2D] {
        guard let wt = collider.worldTransform else { return [] }
        let obb1 = TEOBB(worldTransform: wt, size: collider.boundingBox)
        return checkIntersections(obb1: obb1, excluding: collider, with: otherColliders)
    }
}



//MARK: predictive move
extension TECollisionSystem2D {
    /// Проверяет, с кем из всех коллайдеров столкнётся объект, если его переместить на newWorldTransform.
    func predictiveMoveColliders(sceneNode: TESceneNode2D, newWorldTransform: TETransform2D) -> [TECollider2D] {
        guard !sceneNode.colliders.isEmpty else { return [] }
        var intersectedColliders = [TECollider2D]()
        
        for colliderToMove in sceneNode.colliders {
            // Build OBB for the candidate position/orientation
            let testOBB = TEOBB(worldTransform: newWorldTransform, size: colliderToMove.boundingBox)
            intersectedColliders += checkIntersections(obb1: testOBB, excluding: colliderToMove, with: colliders)
        }
        return intersectedColliders
    }
    
    func predictiveMoveIsInsideSceneBounds(sceneNode: TESceneNode2D, newWorldTransform: TETransform2D, sceneBounds: TEAABB) -> Bool {
        var isInsideSceneBounds = true
        for colliderToMove in sceneNode.colliders {
            let obb = TEOBB(worldTransform: newWorldTransform, size: colliderToMove.boundingBox)
            if !obb.isFullyInsideAABB(sceneBounds) {
                isInsideSceneBounds = false
            }
        }
        return isInsideSceneBounds
    }
    
    
    public func predictiveMove(sceneNode: TESceneNode2D, newWorldTransform: TETransform2D, sceneBounds: TEAABB) -> TEPredictiveMoveResult {
        
        var result = TEPredictiveMoveResult(isInsideSceneBounds: true, colliders: [])
        guard !TESettings2D.DISABLE_COLLISIONS else {
            return result
        }
        
        result.colliders = predictiveMoveColliders(sceneNode: sceneNode,
                                                   newWorldTransform: newWorldTransform)
        result.isInsideSceneBounds = predictiveMoveIsInsideSceneBounds(sceneNode: sceneNode,
                                                                       newWorldTransform: newWorldTransform,
                                                                       sceneBounds: sceneBounds)
        
        for child in sceneNode.children {
            let childWorld = newWorldTransform * child.transform
            result = result.concat(with:
                predictiveMove(sceneNode: child,
                               newWorldTransform: childWorld,
                               sceneBounds: sceneBounds))
        }
        
        return result
    }
}
