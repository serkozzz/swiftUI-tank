//
//  TETankEngine2D+predictiveMove.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 12.10.2025.
//

import SwiftUI
import simd

// MARK: - Convenience predictive move/rotate overloads
extension TETankEngine2D {
    
    /// Predictive check for a new local position (translation only).
    public func predictiveMove(sceneNode: TESceneNode2D, newLocalPosition: SIMD2<Float>) -> TEPredictiveMoveResult {
        let candidate = TETransform2D(sceneNode.transform)
        candidate.setPosition(newLocalPosition)
        return predictiveMove(sceneNode: sceneNode, newLocalTransform: candidate)
    }
    
    /// Predictive check for a local translation delta (pre-multiplied).
    public func predictiveMove(sceneNode: TESceneNode2D, localDelta: SIMD2<Float>) -> TEPredictiveMoveResult {
        let candidate = TETransform2D(sceneNode.transform)
        candidate.move(localDelta)
        return predictiveMove(sceneNode: sceneNode, newLocalTransform: candidate)
    }
    
    /// Predictive check for a new rotation (position preserved).
    public func predictiveRotate(sceneNode: TESceneNode2D, newLocalRotation angleCW: Angle) -> TEPredictiveMoveResult {
        let candidate = TETransform2D(sceneNode.transform)
        candidate.setRotation(clockwiseAngle: angleCW)
        return predictiveMove(sceneNode: sceneNode, newLocalTransform: candidate)
    }
    
    /// Predictive check for a delta rotation (position preserved).
    public func predictiveRotate(sceneNode: TESceneNode2D, localDeltaRotation angleCW: Angle) -> TEPredictiveMoveResult {
        let candidate = TETransform2D(sceneNode.transform)
        candidate.rotate(angleCW)
        return predictiveMove(sceneNode: sceneNode, newLocalTransform: candidate)
    }
    
    /// Predictive check for a full local transform (T * R).
    public func predictiveMove(sceneNode: TESceneNode2D, newLocalTransform: TETransform2D) -> TEPredictiveMoveResult {
        let parentWorld: TETransform2D = (sceneNode.parent != nil) ? sceneNode.parent!.worldTransform : .identity
        let newWorldTransform = parentWorld * newLocalTransform
        return predictiveMove(sceneNode: sceneNode, newWorldTransform: newWorldTransform)
    }
    
    // MARK: - World-space convenience overloads
    
    /// Predictive check for a new world position (translation only).
    public func predictiveMove(sceneNode: TESceneNode2D, newWorldPosition: SIMD2<Float>) -> TEPredictiveMoveResult {
        let candidate = TETransform2D(sceneNode.worldTransform)
        candidate.setPosition(newWorldPosition)
        return predictiveMove(sceneNode: sceneNode, newWorldTransform: candidate)
    }
    
    /// Predictive check for a world translation delta (pre-multiplied).
    public func predictiveMove(sceneNode: TESceneNode2D, worldDelta: SIMD2<Float>) -> TEPredictiveMoveResult {
        let candidate = TETransform2D(sceneNode.worldTransform)
        candidate.move(worldDelta)
        return predictiveMove(sceneNode: sceneNode, newWorldTransform: candidate)
    }
}
