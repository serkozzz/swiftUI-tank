//
//  PreviewableMacro.swift
//  TankEngine2D
//
//  Created by Sergey Kozlov on 13.11.2025.
//

import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct TEPreviewableMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        return []
    }
}



// ---------- 1) Макрос на свойство: просто маркер ----------
public struct TESerializableMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Ничего не генерируем, атрибут используется как маркер
        return []
    }
}

// ---------- 2) Макрос на тип: генерит printSerializableProperties() ----------
public struct TESerializableTypeMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {

        // Нас интересуют только struct / class — DeclGroupSyntax уже подходит
        let typeDecl: DeclGroupSyntax = declaration

        var markedPropertyNames: [String] = []

        for member in typeDecl.memberBlock.members {
            guard let varDecl = member.decl.as(VariableDeclSyntax.self) else { continue }

            // Пропускаем static
            if varDecl.modifiers.contains(where: { $0.name.tokenKind == .keyword(.static) }) == true {
                continue
            }

            // Пропускаем computed
            if varDecl.bindings.contains(where: { $0.accessorBlock != nil }) {
                continue
            }

            // Проверяем, есть ли у свойства атрибут @TESerializable
            let hasAttr = (varDecl.attributes).contains { attr in
                guard let a = attr.as(AttributeSyntax.self) else { return false }
                return a.attributeName.trimmedDescription == "TESerializable"
            }

            guard hasAttr else { continue }

            // Берём имя переменной (binding-ов может быть несколько, но для простоты – первый)
            guard let pattern = varDecl.bindings.first?.pattern
                .as(IdentifierPatternSyntax.self)
            else { continue }

            markedPropertyNames.append(pattern.identifier.text)
        }

        // Если нет отмеченных св-в – сгенерим stub
        if markedPropertyNames.isEmpty {
            let funcDecl: DeclSyntax = """
            func printSerializableProperties() {
                print("[TESerializable] no marked properties")
            }
            """
            return [funcDecl]
        }

        // Строим строку: "serializable: \(self.a), \(self.b), ..."
        let interpolatedSegments: [String] =
            markedPropertyNames.enumerated().map { index, name in
                let prefix = index == 0 ? "" : ", "
                return "\(prefix)\\(self.\(name))"
            }

        let interpolatedBody = interpolatedSegments.joined()
        let literal = "\"serializable: \(interpolatedBody)\""

        let funcDecl: DeclSyntax = """
        func printSerializableProperties() {
            print(\(raw: literal))
        }
        """
        return [funcDecl]
    }
}
