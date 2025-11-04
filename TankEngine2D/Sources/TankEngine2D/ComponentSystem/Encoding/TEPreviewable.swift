//
//  TEPreviewable.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 04.11.2025.
//


protocol TEPreviewable2DProtocol {
    var valueType: Codable.Type { get }
}


public class TEPreviewable2D<T: Codable> {
    public var value: T
    public init(_ value: T) {
        self.value = value
    }
    
    func getType() -> T.Type {
        type(of: value)
    }
    
    static func getType() -> T.Type {
        return T.self
    }
}

extension TEPreviewable2D: TEPreviewable2DProtocol {
    var valueType: Codable.Type { T.self }
}
