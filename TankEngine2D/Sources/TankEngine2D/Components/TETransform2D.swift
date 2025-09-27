//
//  Transform.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 24.09.2025.
//


import SwiftUI
import simd

public class TETransform2D: ObservableObject {
    
    @Published var matrix: Matrix = .identity
    
    public init(position: SIMD2<Float> = .zero) {
        matrix = Matrix(translation: position)
    }
    
    public var position: SIMD2<Float> {
        get {
            SIMD2<Float> (matrix.columns.2.x, matrix.columns.2.y)
        }
        set {
            var newMatrix = matrix
            newMatrix.columns.2.x = newValue.x
            newMatrix.columns.2.y = newValue.y
            matrix = newMatrix
        }
    }
    
//    var cgPosition: CGPoint {
//        CGPoint(x: Double(matrix.columns.2.x), y: Double(matrix.columns.2.y))
//    }
    
    public func move(_ vector: SIMD2<Float>) {
        let translaitonMatrix = Matrix(
            rows: [
                SIMD3( 1,  0, vector.x),
                SIMD3( 0,  1, vector.y),
                SIMD3( 0,  0, 1)]
        )
        matrix = translaitonMatrix * matrix
    }
}
