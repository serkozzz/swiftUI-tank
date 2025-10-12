//
//  matrix_float3x3.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 24.09.2025.
//

import SwiftUI
import simd

///represents column-major matrix
public typealias Matrix = matrix_float3x3


public extension Matrix {
    static var identity: Matrix {
        .init(diagonal: .one)
    }
    
    init(translation: SIMD2<Float>) {
        self = Matrix(
            columns: (
                SIMD3(1, 0, 0),
                SIMD3(0, 1, 0),
                SIMD3(translation.x, translation.y, 1)
            )
        )
    }
    
    init(clockwiseAngle: Angle) {
        let theta = Float(clockwiseAngle.radians)
        let cos = cos(theta)
        let sin = sin(theta)
        
        // colum-major матрица поворота (вокруг (0,0)):
        // [  c   s   0 ]
        // [ -s   c   0 ]
        // [  0   0   1 ]
        self = Matrix(
            rows: [
                SIMD3( cos,  sin,  0),
                SIMD3(-sin,  cos,  0),
                SIMD3(   0,    0,  1)
            ]
        )
    }
}


