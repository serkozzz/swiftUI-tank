//
//  SIMD3.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 15.10.2025.
//

import Foundation
import CoreGraphics

public extension SIMD3<Float> {
    func cgPoint() -> CGPoint {
        CGPoint(x: CGFloat(x), y: CGFloat(y))
    }
}
