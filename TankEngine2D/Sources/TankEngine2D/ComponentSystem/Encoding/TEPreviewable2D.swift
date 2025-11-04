//
//  TEPreviewable.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 04.11.2025.
//


protocol TEPreviewable2DProtocol {
    var valueType: Codable.Type { get }
    var value: Codable { get }
    func setValue(_ value: Codable) -> Bool
}


public class TEPreviewable2D<T: Codable> {
    public var _value: T
    public init(_ value: T) {
        self._value = value
    }
}


extension TEPreviewable2D: TEPreviewable2DProtocol {
    var valueType: Codable.Type { T.self }
    var value: Codable { _value }
    func setValue(_ value: Codable) -> Bool {
        guard let casted = value as? T else { return false }
        _value = casted
        return true
    }
}
