//
//  Camera.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 20.09.2025.
//
import simd
import SwiftUI

typealias Matrix = matrix_float3x3
class Camera: ObservableObject {
    
    @Published var transform = Matrix(diagonal: .one)
    
    func move(_ vector: SIMD2<Float>) {
        let matrix = Matrix(
            rows: [
                SIMD3( 1,  0, vector.x),
                SIMD3( 0,  1, vector.y),
                SIMD3( 0,  0, 1)]
        )
        transform = matrix * transform
    }
    
    func screenToWorld(_ point: SIMD2<Float>, viewportSize: CGSize) -> SIMD2<Float> {
        var worldPoint = SIMD3<Float>(point, 1)
        worldPoint.y = Float(viewportSize.height) - worldPoint.y
        
        let result = transform * worldPoint
        return SIMD2<Float>(result.x, result.y)
    }
    
}
