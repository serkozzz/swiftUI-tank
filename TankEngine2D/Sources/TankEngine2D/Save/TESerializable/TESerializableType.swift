//
//  Untitled.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 15.11.2025.
//

@MainActor
public protocol TESerializableType {
    func encodeSerializableProperties() -> [String: String]
    func decodeSerializableProperties(_ dict: [String: String])
}
