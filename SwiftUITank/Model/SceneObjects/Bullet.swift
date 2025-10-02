//
//  Bullet.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 30.09.2025.
//
import Foundation
import CoreGraphics
import simd

class Bullet: BaseSceneObject {
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
    
    let speed: Speed
    let size: Size
    
    let startPosition: SIMD2<Float>
    let normalizedDirection: SIMD2<Float>
    
    init(startPosition: SIMD2<Float>,
         directionVector: SIMD2<Float>,
         speed: Speed = .normal,
         size: Size = .normal
    ) {
        self.startPosition = startPosition
        self.normalizedDirection = simd_normalize(directionVector)
        self.speed = speed
        self.size = size
    }
    
    override func start() {
        guard let go = owner?.geometryObject else { return }
        go.boundingBox = size.cgSize
    }
    
    override func update(timeFromLastUpdate: TimeInterval) {
        guard let go = owner?.geometryObject else { return }
        go.transform?.move(normalizedDirection * speed.rawValue * Float(timeFromLastUpdate))
    }
}
