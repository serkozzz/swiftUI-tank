//
//  Transform.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 24.09.2025.
//


import SwiftUI
import simd
import Combine

@MainActor
public class TETransform2D: ObservableObject {
    
    /// the only source of truth
    /// (column-major)
    @Published public private(set) var matrix: Matrix = .identity
    
    // Кастомный паблишер «после изменения»
    public let didChange = PassthroughSubject<Void, Never>()
    
    public init(matrix: Matrix = .identity) {
        self.matrix = matrix
    }
    
    public init(_ other: TETransform2D) {
        self.matrix = other.matrix
    }
    
    public init(position: SIMD2<Float> = .zero) {
        matrix = Matrix(translation: position)
    }
    
    public var position: SIMD2<Float> {
        get {
            SIMD2<Float>(matrix.columns.2.x, matrix.columns.2.y)
        }
        set {
            var newMatrix = matrix
            newMatrix.columns.2.x = newValue.x
            newMatrix.columns.2.y = newValue.y
            matrix = newMatrix
            didChange.send() // эмитим после установки
        }
    }
    
    // Извлекаем угол ПО ЧАСОВОЙ из матрицы (предполагаем, что 2x2 блок — чистый поворот без масштаба/shear)
    public var rotation: Angle {
        // Для формы [ c  s; -s  c ] (column-major):
        // angleCCW = atan2(-m10, m00); angleCW = -angleCCW
        let c = matrix.columns.0.x    // m00
        let minusS = matrix.columns.0.y // m10 = -s
        let angleCCW = atan2(-minusS, c)
        let angleCW = -angleCCW
        return .radians(Double(angleCW))
    }
    
    public func move(_ vector: SIMD2<Float>) {
        let translaitonMatrix = Matrix(
            rows: [
                SIMD3( 1,  0, vector.x),
                SIMD3( 0,  1, vector.y),
                SIMD3( 0,  0, 1)]
        )
        matrix = translaitonMatrix * matrix
        didChange.send() // эмитим после установки
    }
    
    
    
    public func rotate(_ clockwiseAngle: Angle) {
        
        let positionCache = position
        
        var rotationOnlyMatrix: Matrix = matrix
        rotationOnlyMatrix.columns.2.x = 0
        rotationOnlyMatrix.columns.2.y = 0
        
        //create rotationMatrixToApply
        // По часовой стрелке => отрицательный угол в стандартной матрице поворота.
        let theta = Float(-clockwiseAngle.radians)
        let cos = cos(theta)
        let sin = sin(theta)
        
        // colum-major матрица поворота (вокруг (0,0)):
        // [  c   s   0 ]
        // [ -s   c   0 ]
        // [  0   0   1 ]
        let rotationMatrixToApply = Matrix(
            rows: [
                SIMD3( cos,  sin,  0),
                SIMD3(-sin,  cos,  0),
                SIMD3(   0,    0,  1)
            ]
        )
        matrix = rotationMatrixToApply * rotationOnlyMatrix
        position = positionCache
        didChange.send()
    }
    
    static var identity: TETransform2D {
        TETransform2D(matrix: .identity)
    }
}

@MainActor
public func * (lhs: TETransform2D, rhs: TETransform2D) -> TETransform2D {
    TETransform2D(matrix: lhs.matrix * rhs.matrix)
}
