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

@attached(peer)
public macro TESerializable() = #externalMacro(
    module: "TankEngine2DMacros",
    type: "TESerializableMacro"
)

@attached(
    member,
    names:
        named(printSerializableProperties),
        named(decodeSerializableProperties),
        named(encodeSerializableProperties)
)
@attached(
    extension,
    conformances: TESerializable
)
public macro TESerializableType() = #externalMacro(
    module: "TankEngine2DMacros",
    type: "TESerializableTypeMacro"
)
