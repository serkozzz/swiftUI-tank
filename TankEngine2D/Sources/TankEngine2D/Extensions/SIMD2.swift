//
//  SIMD2.swift
//  SwiftUITank
//
//  Created by Sergey Kozlov on 20.09.2025.
//
import Foundation
import CoreGraphics

public extension SIMD2<Float> {
    init(_ point: CGPoint) {
        self.init(x: Float(point.x), y: Float(point.y))
    }
    
    init(cgSize: CGSize) {
        self.init(x: Float(cgSize.width), y: Float(cgSize.height))
    }
    
    init(_ simd3: SIMD3<Float>) {
        self.init(x: simd3.x, y: simd3.y)
    }
    
    func cgPoint() -> CGPoint {
        CGPoint(x: CGFloat(x), y: CGFloat(y))
    }
}

extension SIMD2: Codable where Scalar == Float {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        // Поддержим и объектный формат {"x":..,"y":..} на всякий случай
        if let dict = try? container.decode([String: Float].self),
           let x = dict["x"], let y = dict["y"] {
            self.init(x, y)
            return
        }
        // Основной формат — массив [x, y]
        let array = try container.decode([Float].self)
        guard array.count == 2 else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Expected [x,y]")
        }
        self.init(array[0], array[1])
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode([x, y])
    }
}
