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
    
    private(set) var spawner: BaseSceneObject!
    private(set) var speed: Speed!
    private(set) var size: Size!
    
    private(set) var startPosition: SIMD2<Float>!
    private(set) var normalizedDirection: SIMD2<Float>!
    
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
    
    func initFrom(other: Bullet) {
        self.spawner = other.spawner
        self.startPosition = other.startPosition
        self.normalizedDirection = other.normalizedDirection
        self.speed = other.speed
        self.size = other.size
        self.health = other.health
    }
    
    required init() {
        super.init()
    }
    
    override func start() {
    }
    
    override func update(timeFromLastUpdate: TimeInterval) {
        transform?.move(normalizedDirection * speed.rawValue * Float(timeFromLastUpdate))
    }
    
    override func collision(collider: TECollider2D) {
        onCollision?(self, collider)
    }
}
