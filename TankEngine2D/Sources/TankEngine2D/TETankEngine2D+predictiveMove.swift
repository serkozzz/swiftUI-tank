//
//  Untitled.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 12.10.2025.
//

import SwiftUI

// MARK: - Удобные локальные перегрузки
extension TETankEngine2D {
    
    public func predictiveMove(sceneNode: TESceneNode2D, newLocalPosition: SIMD2<Float>) -> TEPredictiveMoveResult {
        let candidate = TETransform2D(sceneNode.transform)
        candidate.setPosition(newLocalPosition)
        return predictiveMove(sceneNode: sceneNode, newLocalTransform: candidate)
    }
    
    public func predictiveMove(sceneNode: TESceneNode2D, localDelta: SIMD2<Float>) -> TEPredictiveMoveResult {
        let candidate = TETransform2D(sceneNode.transform)
        candidate.move(localDelta)
        return predictiveMove(sceneNode: sceneNode, newLocalTransform: candidate)
    }
    
    public func predictiveRotate(sceneNode: TESceneNode2D, newLocalRotation angleCW: Angle) -> TEPredictiveMoveResult {
        let candidate = TETransform2D(sceneNode.transform)
        candidate.setRotation(clockwiseAngle: angleCW)
        return predictiveMove(sceneNode: sceneNode, newLocalTransform: candidate)
    }
    
    public func predictiveRotate(sceneNode: TESceneNode2D, localDeltaRotation angleCW: Angle) -> TEPredictiveMoveResult {
        let candidate = TETransform2D(sceneNode.transform)
        candidate.rotate(angleCW)
        return predictiveMove(sceneNode: sceneNode, newLocalTransform: candidate)
    }
    
    public func predictiveMove(sceneNode: TESceneNode2D, newLocalTransform: TETransform2D) -> TEPredictiveMoveResult {
        let parentTransform = (sceneNode.parent != nil) ? sceneNode.parent!.worldTransform : .identity
        let newWorldTransform = parentTransform * newLocalTransform
        
        return predictiveMove(sceneNode: sceneNode, newWorldTransform: newWorldTransform)
    }
    
    // MARK: - Удобные мировые перегрузки
    public func predictiveMove(sceneNode: TESceneNode2D, newWorldPosition: SIMD2<Float>) -> TEPredictiveMoveResult {
        let candidate = TETransform2D(sceneNode.worldTransform)
        candidate.setPosition(newWorldPosition)
        return predictiveMove(sceneNode: sceneNode, newWorldTransform: candidate)
    }
    
    public func predictiveMove(sceneNode: TESceneNode2D, worldDelta: SIMD2<Float>) -> TEPredictiveMoveResult {
        let candidate = TETransform2D(sceneNode.worldTransform)
        candidate.move(worldDelta)
        return predictiveMove(sceneNode: sceneNode, newWorldTransform: candidate)
    }
}
