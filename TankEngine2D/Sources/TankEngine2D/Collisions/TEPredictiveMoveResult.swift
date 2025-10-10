//
//  PredictiveMoveResult.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 10.10.2025.
//



public struct TEPredictiveMoveResult {
    public var isInsideSceneBounds: Bool
    public var colliders: [TECollider2D]
    
    func concat(with other: TEPredictiveMoveResult) -> TEPredictiveMoveResult {
        return .init(isInsideSceneBounds: self.isInsideSceneBounds && other.isInsideSceneBounds,
                     colliders: self.colliders + other.colliders)
    }
}
