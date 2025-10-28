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

extension Matrix: Codable {
    private struct Columns: Codable {
        var c0: SIMD3<Float>
        var c1: SIMD3<Float>
        var c2: SIMD3<Float>
    }
    
    public init(from decoder: Decoder) throws {
        // Поддержим два формата:
        // 1) Явный объект с полями c0/c1/c2 (каждый SIMD3<Float>)
        // 2) Массив [[Float]] длиной 3, каждая подмассив длиной 3 — column-major
        let container = try decoder.singleValueContainer()
        if let cols = try? container.decode(Columns.self) {
            self = Matrix(columns: (cols.c0, cols.c1, cols.c2))
            return
        }
        // Попробуем массив массивов
        let array = try container.decode([[Float]].self)
        guard array.count == 3, array.allSatisfy({ $0.count == 3 }) else {
            throw DecodingError.dataCorruptedError(in: container,
                                                   debugDescription: "Expected 3x3 column-major array")
        }
        let c0 = SIMD3<Float>(array[0][0], array[0][1], array[0][2])
        let c1 = SIMD3<Float>(array[1][0], array[1][1], array[1][2])
        let c2 = SIMD3<Float>(array[2][0], array[2][1], array[2][2])
        self = Matrix(columns: (c0, c1, c2))
    }
    
    public func encode(to encoder: Encoder) throws {
        // Кодируем как массив 3 столбцов по 3 значения (column-major)
        var container = encoder.singleValueContainer()
        let c0 = [columns.0.x, columns.0.y, columns.0.z]
        let c1 = [columns.1.x, columns.1.y, columns.1.z]
        let c2 = [columns.2.x, columns.2.y, columns.2.z]
        try container.encode([c0, c1, c2])
    }
}
