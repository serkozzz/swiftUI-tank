import Foundation
import SwiftParser
import SwiftSyntax

// MARK: - Visitor
final class TypeCollectorVisitor: SyntaxVisitor {
    private let targetNames: Set<String>
    private(set) var found: Set<String> = []

    init(targetNames: some Sequence<String>, viewMode: SyntaxTreeViewMode) {
        self.targetNames = Set(targetNames)
        super.init(viewMode: viewMode)
    }

    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        processInherited(node.inheritanceClause, typeName: node.name.text)
        return .skipChildren
    }

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        processInherited(node.inheritanceClause, typeName: node.name.text)
        return .skipChildren
    }

    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        processInherited(node.inheritanceClause, typeName: node.name.text)
        return .skipChildren
    }

    override func visit(_ node: ExtensionDeclSyntax) -> SyntaxVisitorContinueKind {
        guard let clause = node.inheritanceClause else { return .skipChildren }
        // Проверяем, что расширение объявляет соответствие одному из целевых протоколов
        var matchesTarget = false
        for inherited in clause.inheritedTypes {
            let base = inherited.type.description
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if targetNames.contains(base) {
                matchesTarget = true
                break
            }
        }
        guard matchesTarget else { return .skipChildren }

        // Извлекаем имя расширяемого типа
        if let typeName = extractBaseTypeName(from: node.extendedType) {
            found.insert(typeName)
        }

        return .skipChildren
    }

    private func processInherited(_ clause: InheritanceClauseSyntax?, typeName: String) {
        guard let clause else { return }
        for inherited in clause.inheritedTypes {
            let base = inherited.type.description
                .trimmingCharacters(in: .whitespacesAndNewlines)
            if targetNames.contains(base) {
                found.insert(typeName)
                break
            }
        }
    }

    // Извлекает базовое имя типа из TypeSyntax расширения:
    // - Namespace.TankView -> TankView
    // - TankView<Foo, Bar> -> TankView
    // - Просто TankView -> TankView
    private func extractBaseTypeName(from type: TypeSyntax) -> String? {
        let text = type.description.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return nil }

        // Отбрасываем generic-часть: "TankView<Foo, Bar>" -> "TankView"
        let withoutGenerics: String
        if let angleIndex = text.firstIndex(of: "<") {
            withoutGenerics = String(text[..<angleIndex])
        } else {
            withoutGenerics = text
        }

        // Берём правый идентификатор после точки: "Namespace.TankView" -> "TankView"
        if let lastDot = withoutGenerics.lastIndex(of: ".") {
            let afterDot = withoutGenerics.index(after: lastDot)
            let name = String(withoutGenerics[afterDot...]).trimmingCharacters(in: .whitespacesAndNewlines)
            return name.isEmpty ? nil : name
        } else {
            let name = withoutGenerics.trimmingCharacters(in: .whitespacesAndNewlines)
            return name.isEmpty ? nil : name
        }
    }
}

// MARK: - Entry
let args = CommandLine.arguments
guard args.count == 3 else {
    fatalError("Usage: <exec> <srcRoot> <outputFile>")
}

let srcRoot = URL(fileURLWithPath: args[1])
let output  = URL(fileURLWithPath: args[2])

var allComponents = Set<String>()
var allViews = Set<String>()

if let enumerator = FileManager.default.enumerator(
    at: srcRoot,
    includingPropertiesForKeys: nil
) {
    for case let fileURL as URL in enumerator {
        guard fileURL.pathExtension == "swift" else { continue }

        let source = try String(contentsOf: fileURL)
        let tree = Parser.parse(source: source)

        // Один проход: собираем и компоненты, и вью
        let componentVisitor = TypeCollectorVisitor(targetNames: ["TEComponent2D"], viewMode: .all)
        componentVisitor.walk(tree)
        allComponents.formUnion(componentVisitor.found)

        let viewVisitor = TypeCollectorVisitor(targetNames: ["TEView2D"], viewMode: .all)
        viewVisitor.walk(tree)
        allViews.formUnion(viewVisitor.found)
    }
}

let uniqueComponents = Array(allComponents).sorted()
let uniqueViews = Array(allViews).sorted()

// MARK: - Генерация итогового файла
let componentEntries = uniqueComponents.map { #"String(reflecting: \#($0).self): \#($0).self"# }
let viewEntries = uniqueViews.map { #"String(reflecting: \#($0).self): \#($0).self"# }

// Формируем литералы словарей с учетом пустоты
let componentsDictLiteral: String = {
    if componentEntries.isEmpty {
        return "[:]"
    } else {
        return """
        [
                \(componentEntries.joined(separator: ",\n        "))
            ]
        """
    }
}()

let viewsDictLiteral: String = {
    if viewEntries.isEmpty {
        return "[:]"
    } else {
        return """
        [
                \(viewEntries.joined(separator: ",\n        "))
            ]
        """
    }
}()

let text = """
// AUTO-GENERATED — DO NOT EDIT
// Found components: \(uniqueComponents.count)
// Found views: \(uniqueViews.count)

import TankEngine2D

@MainActor
public final class TEAutoRegistrator2D: TEAutoRegistratorProtocol {
    public let components: [String: TEComponent2D.Type] = \(componentsDictLiteral)
    public let views: [String: any TEView2D.Type] = \(viewsDictLiteral)
}
"""

try text.write(to: output, atomically: true, encoding: .utf8)
