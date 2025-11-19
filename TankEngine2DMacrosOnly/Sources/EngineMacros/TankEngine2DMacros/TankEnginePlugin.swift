//
//  TankEnginePlugin.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 13.11.2025.
//

import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct TankEnginePlugin: CompilerPlugin {
    let providingMacros: [any Macro.Type] = [
        TEPreviewableMacro.self,
        TESerializableMacro.self,
        TESerializableTypeMacro.self
    ]
}
