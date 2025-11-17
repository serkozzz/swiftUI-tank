//
//  TELogger2D.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 28.10.2025.
//

public enum TELogger2D {
    @inlinable
    public static func warning(_ message: String) {
        Swift.print("⚠️ [TankEngine2D][WARNING] \(message)")
    }

    @inlinable
    public static func error(_ message: String) {
        Swift.print("❌ [TankEngine2D][ERROR] \(message)")
    }

    @inlinable
    public static func info(_ message: String) {
        Swift.print("ℹ️ [TankEngine2D][INFO] \(message)")
    }
}
