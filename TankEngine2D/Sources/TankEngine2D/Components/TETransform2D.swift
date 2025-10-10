//
//  Transform.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 24.09.2025.
//


import SwiftUI
import simd

@MainActor
public class TETransform2D: ObservableObject {
    
    @Published var matrix: Matrix = .identity
    
    public init(matrix: Matrix = .identity) {
        self.matrix = matrix
    }
    
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
    
    public var worldPosition: SIMD2<Float> {
        position
    }
    
    var cgWorldPosition: CGPoint {
        CGPoint(x: Double(matrix.columns.2.x), y: Double(matrix.columns.2.y))
    }
    
    public func move(_ vector: SIMD2<Float>) {
        let translaitonMatrix = Matrix(
            rows: [
                SIMD3( 1,  0, vector.x),
                SIMD3( 0,  1, vector.y),
                SIMD3( 0,  0, 1)]
        )
        matrix = translaitonMatrix * matrix
    }
    
    static var identity: TETransform2D {
        TETransform2D(matrix: .identity)
    }
}

@MainActor
public func * (lhs: TETransform2D, rhs: TETransform2D) -> TETransform2D {
    TETransform2D(matrix: lhs.matrix * rhs.matrix)
}
