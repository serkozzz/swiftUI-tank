//
//  Macros.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 13.11.2025.
//

@attached(peer)
public macro TEPreviewable() = #externalMacro(
    module: "TankEngine2DMacros",
    type: "TEPreviewableMacro"
)
