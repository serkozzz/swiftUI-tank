//
//  SIMD3.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 15.10.2025.
//

import Foundation
import CoreGraphics

public extension SIMD3<Float> {
    func cgPoint() -> CGPoint {
        CGPoint(x: CGFloat(x), y: CGFloat(y))
    }
}

extension SIMD3: Codable where Scalar == Float {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        // Поддержим и объектный формат {"x":..,"y":..,"z":..} на всякий случай
        if let dict = try? container.decode([String: Float].self),
           let x = dict["x"], let y = dict["y"], let z = dict["z"] {
            self.init(x, y, z)
            return
        }
        // Основной формат — массив [x, y, z]
        let array = try container.decode([Float].self)
        guard array.count == 3 else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Expected [x,y,z]")
        }
        self.init(array[0], array[1], array[2])
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode([x, y, z])
    }
}
