//
//  Macros.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 13.11.2025.
//

#if TE2D_SPM

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
public macro TESerializableType() = #externalMacro(
    module: "TankEngine2DMacros",
    type: "TESerializableTypeMacro"
)

#endif
