//
//  TEAABB.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 05.10.2025.
//

import SwiftUI
import simd

// Простая осево-ориентированная рамка (AABB) с центром и размером.
struct TEAABB {
    var center: SIMD2<Float>
    var size: CGSize
    
    init(center: SIMD2<Float>, size: CGSize) {
        self.center = center
        self.size = size
    }
    
    init(rect: CGRect) {
        self.center = SIMD2<Float>(Float(rect.midX), Float(rect.midY))
        self.size = rect.size
    }
    

    
    var half: SIMD2<Float> {
        SIMD2<Float>(Float(size.width) * 0.5, Float(size.height) * 0.5)
    }
    var min: SIMD2<Float> { center - half }
    var max: SIMD2<Float> { center + half }
}


extension TEAABB {
    // Касание по грани считаем пересечением.
    func intersects(_ other: TEAABB) -> Bool {
        let separatedX = (self.max.x < other.min.x) || (other.max.x < self.min.x)
        if separatedX { return false }
        
        let separatedY = (self.max.y < other.min.y) || (other.max.y < self.min.y)
        if separatedY { return false }
        
        return true
    }
    
    
    // Полное включение AABB внутрь другого AABB (касание границы допускается).
    func isFullyInside(_ other: TEAABB) -> Bool {
        return self.min.x >= other.min.x &&
               self.max.x <= other.max.x &&
               self.min.y >= other.min.y &&
               self.max.y <= other.max.y
    }
}
