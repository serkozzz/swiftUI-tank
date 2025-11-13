//
//  PreviewableMacro.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 13.11.2025.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxMacros

public struct TEPreviewableMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // пока просто возвращаем пустой список, без генерации кода
        return []
    }
}
