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
}
