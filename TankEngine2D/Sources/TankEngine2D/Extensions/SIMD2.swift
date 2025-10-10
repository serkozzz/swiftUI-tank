//
//  SIMD2.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 20.09.2025.
//
import Foundation
import CoreGraphics

public extension SIMD2<Float> {
    init(_ point: CGPoint) {
        self.init(x: Float(point.x), y: Float(point.y))
    }
    
    init(cgSize: CGSize) {
        self.init(x: Float(cgSize.width), y: Float(cgSize.height))
    }
    
    init(_ simd3: SIMD3<Float>) {
        self.init(x: simd3.x, y: simd3.y)
    }

}
