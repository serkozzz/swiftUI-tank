//
//  Bullet.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 30.09.2025.
//
import Foundation
import CoreGraphics
import TankEngine2D
import simd

class Bullet: DamagableObject {
    enum Speed: Float {
        case slow = 50
        case normal = 100
        case fast = 200
    }
    
    enum Size {
        case little
        case normal
        case big
        
        var cgSize: CGSize {
            switch self {
            case .little:
                return CGSize(width: 2, height: 2)
            case .normal:
                return CGSize(width: 4, height: 4)
            case .big:
                return CGSize(width: 10, height: 10)
            }
        }
    }
    
    let spawner: BaseSceneObject
    let speed: Speed
    let size: Size
    
    let startPosition: SIMD2<Float>
    let normalizedDirection: SIMD2<Float>
    
    var onCollision: ((Bullet, TECollider2D) -> Void)?
    
    init(_ spawner: BaseSceneObject,
         startPosition: SIMD2<Float>,
         directionVector: SIMD2<Float>,
         speed: Speed = .normal,
         size: Size = .normal
    ) {
        self.spawner = spawner
        self.startPosition = startPosition
        self.normalizedDirection = simd_normalize(directionVector)
        self.speed = speed
        self.size = size
        super.init(health: 100)
    }
    
    override func start() {
        guard let go = owner?.geometryObject else { return }
        go.boundingBox = size.cgSize
    }
    
    override func update(timeFromLastUpdate: TimeInterval) {
        guard let go = owner?.geometryObject else { return }
        go.transform?.move(normalizedDirection * speed.rawValue * Float(timeFromLastUpdate))
    }
    
    override func collision(collider: TECollider2D) {
        onCollision?(self, collider)
    }
}
