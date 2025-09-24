//
//  matrix_float3x3.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 24.09.2025.
//

import simd

typealias Matrix = matrix_float3x3

extension Matrix {
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
}


