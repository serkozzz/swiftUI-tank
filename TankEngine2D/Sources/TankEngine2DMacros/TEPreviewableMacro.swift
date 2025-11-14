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
        // извлечём имя переменной
        guard
            let varDecl = declaration.as(VariableDeclSyntax.self),
            let name = varDecl.bindings.first?.pattern.as(IdentifierPatternSyntax.self)?.identifier.text
        else {
            return []
        }
        
        let printFunc: DeclSyntax = """
               func print_\(raw: name)() {
                   print(\(raw: name))
               }
               """
        
        return [printFunc]
    }
}

