//
//  SIMD2.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 20.09.2025.
//
import Foundation

extension SIMD2<Float> {
    init(_ point: CGPoint) {
        self.init(x: Float(point.x), y: Float(point.y)) 
    }
}
