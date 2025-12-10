//
//  AnyOptional.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 10.12.2025.
//

import Foundation

// Протокол для получения wrappedType у Optional через типовую акробатику
public protocol AnyOptionalProtocol {
    static var wrappedType: Any.Type { get }
}

extension Optional: AnyOptionalProtocol {
    static public var wrappedType: Any.Type { Wrapped.self }
}

public func unwrapOptionalType(_ type: Any.Type) -> Any.Type {
    if let optionalProtocol = type as? any AnyOptionalProtocol.Type {
        return optionalProtocol.wrappedType
    }
    return type
}
