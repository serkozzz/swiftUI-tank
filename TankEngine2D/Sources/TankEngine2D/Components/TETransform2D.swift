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
public class TETransform2D: @MainActor Codable, ObservableObject {
    
    /// the only source of truth
    /// (column-major)
    @Published public private(set) var matrix: Matrix = .identity
    
    // Кастомный паблишер «после изменения»
    public let didChange = PassthroughSubject<Void, Never>()
    
    private var stashedPosition : SIMD2<Float> = .zero
    
    public init(matrix: Matrix = .identity) {
        self.matrix = matrix
    }
    
    public init(_ other: TETransform2D) {
        self.matrix = other.matrix
    }
    
    public init(position: SIMD2<Float> = .zero, clockwiseRotation angle: Angle = .zero) {
        matrix = Matrix(clockwiseAngle: angle)
        setPosition(position)
    }
    

    
    public var position: SIMD2<Float> {
        get {
            SIMD2<Float>(matrix.columns.2.x, matrix.columns.2.y)
        }
    }
    
    public func setPosition(_ position: SIMD2<Float>) {
            matrix.columns.2.x = position.x
            matrix.columns.2.y = position.y
            didChange.send() // эмитим после установки
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
    
    public func setRotation(clockwiseAngle angle: Angle) {
        stashPosition()
        matrix = Matrix(clockwiseAngle: angle)
        unstashPosition()
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
        stashPosition()
        let rotationMatrixToApply = Matrix(clockwiseAngle: clockwiseAngle)
        matrix = rotationMatrixToApply * matrix
        unstashPosition()
        didChange.send()
    }
    
    static var identity: TETransform2D {
        TETransform2D(matrix: .identity)
    }
    
    //MARK: Codable
    enum CodingKeys: CodingKey {
        case matrix
    }
    
    public required init(from decoder: Decoder) throws {

        let c = try decoder.container(keyedBy: CodingKeys.self)
        matrix = try c.decode(Matrix.self, forKey: .matrix)
    }

    public func encode(to encoder: Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(matrix, forKey: .matrix)
    }
}


extension TETransform2D {
    private func stashPosition() {
        self.stashedPosition = position
        self.setPosition(.zero)
    }
    
    private func unstashPosition() {
        self.setPosition(stashedPosition)
    }
    
    
    
}

@MainActor
public func * (lhs: TETransform2D, rhs: TETransform2D) -> TETransform2D {
    TETransform2D(matrix: lhs.matrix * rhs.matrix)
}

