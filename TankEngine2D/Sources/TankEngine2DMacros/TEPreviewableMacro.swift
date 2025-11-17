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
import SwiftDiagnostics

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

// Вынесено на уровень файла, чтобы не ругалось на вложенный тип в generic-функции
fileprivate struct PropInfo {
    let name: String
    let typeSyntax: String? // nil если тип не указан явно
    init(name: String, typeSyntax: String?) {
        self.name = name
        self.typeSyntax = typeSyntax
    }
}

// Сообщения диагностик
fileprivate struct TESerializableTypeDiagnostic: DiagnosticMessage {
    enum Kind {
        case missingExplicitType(property: String)
    }

    let kind: Kind

    var message: String {
        switch kind {
        case .missingExplicitType(let property):
            return "@TESerializable requires an explicit type annotation for property '\(property)'. Please specify the type explicitly, e.g. '@TESerializable var \(property): SomeType = …'"
        }
    }

    var diagnosticID: MessageID {
        switch kind {
        case .missingExplicitType:
            return .init(domain: "TESerializableTypeMacro", id: "MissingExplicitType")
        }
    }

    var severity: DiagnosticSeverity { .error }
}

// Маркерный макрос типа
public struct TESerializableTypeMacro {}

// ---------- Генерация членов: print/encode/decode ----------
extension TESerializableTypeMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {

        let typeDecl: DeclGroupSyntax = declaration

        // Имя типа для логов (если понадобится)
        let typeNameForLogs: String = {
            if let cls = declaration.as(ClassDeclSyntax.self) {
                return cls.name.text
            }
            return "<UnknownType>"
        }()

        // Собираем свойства текущего класса
        // - marked: только с @TESerializable (для "selected" encode/decode/print)
        var markedPropertyNames: [String] = []
        var markedProps: [PropInfo] = []

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

            // Проверка на @TESerializable
            let hasSerializableAttr = (varDecl.attributes).contains { attr in
                guard let a = attr.as(AttributeSyntax.self) else { return false }
                return a.attributeName.trimmedDescription == "TESerializable"
            }

            guard hasSerializableAttr else { continue }

            // Разбираем binding (берем только первый — как у вас было)
            guard let binding = varDecl.bindings.first else { continue }
            guard let pattern = binding.pattern.as(IdentifierPatternSyntax.self) else { continue }
            let name = pattern.identifier.text

            // Явный тип для сериализации обязателен
            let explicitType: String?
            if let typeAnn = binding.typeAnnotation?.type {
                explicitType = typeAnn.trimmedDescription
            } else {
                explicitType = nil
                context.diagnose(
                    Diagnostic(
                        node: Syntax(pattern.identifier),
                        message: TESerializableTypeDiagnostic(kind: .missingExplicitType(property: name))
                    )
                )
            }

            markedPropertyNames.append(name)
            markedProps.append(PropInfo(name: name, typeSyntax: explicitType))
        }

        // 1) printSerializableProperties — теперь override + super
        let printFunc: DeclSyntax = {
            if markedPropertyNames.isEmpty {
                return """
                public override func printSerializableProperties() {
                    super.printSerializableProperties()
                    print("[TESerializable] no marked properties")
                }
                """
            } else {
                let interpolatedSegments: [String] =
                    markedPropertyNames.enumerated().map { index, name in
                        let prefix = index == 0 ? "" : ", "
                        return "\(prefix)\(name)=\\(self.\(name))"
                    }
                let interpolatedBody = interpolatedSegments.joined()
                let literal = "serializable: \(interpolatedBody)"
                return """
                public override func printSerializableProperties() {
                    super.printSerializableProperties()
                    print("\(raw: literal)")
                }
                """
            }
        }()

        // 2) encodeSerializableProperties() -> [String: String] (только помеченные)
        let encodeBodyLinesSelected: [String] = {
            var lines = [String]()
            lines.append("var dict = super.encodeSerializableProperties()")
            for prop in markedProps {
                guard prop.typeSyntax != nil else { continue }
                lines.append("""
                do {
                    let data = try JSONEncoder().encode(self.\(prop.name))
                    if let str = String(data: data, encoding: .utf8) {
                        dict["\(prop.name)"] = str
                    }
                } catch {
                    // игнорируем кодировочные ошибки для отдельного поля
                }
                """)
            }
            lines.append("return dict")
            return lines
        }()
        let encodeFuncSelected: DeclSyntax = """
        public override func encodeSerializableProperties() -> [String: String] {
            \(raw: encodeBodyLinesSelected.joined(separator: "\n"))
        }
        """

        // 3) decodeSerializableProperties(_:) (только помеченные)
        let decodeBodyLinesSelected: [String] = {
            var lines = [String]()
            lines.append("super.decodeSerializableProperties(dict)")
            for prop in markedProps {
                guard let typeSyntax = prop.typeSyntax else { continue }
                lines.append("""
                if let json = dict["\(prop.name)"], let data = json.data(using: .utf8) {
                    if let value = try? JSONDecoder().decode(\(typeSyntax).self, from: data) {
                        self.\(prop.name) = value
                    }
                }
                """)
            }
            return lines
        }()
        let decodeFuncSelected: DeclSyntax = """
        public override func decodeSerializableProperties(_ dict: [String: String]) {
            \(raw: decodeBodyLinesSelected.joined(separator: "\n"))
        }
        """

        return [printFunc, encodeFuncSelected, decodeFuncSelected]
    }
}
