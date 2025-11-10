//
//  TEPreviewable2D.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 04.11.2025.
//

import Foundation

public protocol TEPreviewable2D : Codable {
    associatedtype VType: Codable
    var valueType: VType.Type { get }
    var value: VType { get set }
    
    mutating func setValueAny(_ value: any Codable) -> Bool
}

public extension TEPreviewable2D {
    var valueType: VType.Type { VType.self }
    
    mutating func setValueAny(_ value: any Codable) -> Bool {
        guard let casted = value as? VType else { return false }
        self.value = casted
        return true
    }
}

public extension TEPreviewable2D where VType == Self {
    var value: VType {
        get { self }
        set { self = newValue }
    }
}


