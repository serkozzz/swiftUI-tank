import Foundation
import SwiftParser
import SwiftSyntax

// MARK: - Helpers
private func normalizeTypeName(_ raw: String) -> String {
    let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return trimmed }
    // Отбрасываем generic-часть: "TankView<Foo, Bar>" -> "TankView"
    let withoutGenerics: String
    if let angleIndex = trimmed.firstIndex(of: "<") {
        withoutGenerics = String(trimmed[..<angleIndex])
    } else {
        withoutGenerics = trimmed
    }
    // Берём правый идентификатор после точки: "Namespace.TankView" -> "TankView"
    if let lastDot = withoutGenerics.lastIndex(of: ".") {
        let afterDot = withoutGenerics.index(after: lastDot)
        return String(withoutGenerics[afterDot...]).trimmingCharacters(in: .whitespacesAndNewlines)
    } else {
        return withoutGenerics.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

private func extractBaseTypeName(from type: TypeSyntax) -> String? {
    let text = type.description.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !text.isEmpty else { return nil }
    let name = normalizeTypeName(text)
    return name.isEmpty ? nil : name
}

// MARK: - Visitor (collect relations)
final class RelationCollectorVisitor: SyntaxVisitor {
    // typeName -> direct parents/protocols
    private(set) var parentsByType: [String: Set<String>] = [:]

    private func addRelation(child: String, parent: String) {
        guard !child.isEmpty, !parent.isEmpty else { return }
        parentsByType[child, default: []].insert(parent)
    }

    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        let typeName = node.name.text
        if let clause = node.inheritanceClause {
            for inherited in clause.inheritedTypes {
                let parent = normalizeTypeName(inherited.type.description)
                addRelation(child: typeName, parent: parent)
            }
        }
        return .skipChildren
    }

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        let typeName = node.name.text
        if let clause = node.inheritanceClause {
            for inherited in clause.inheritedTypes {
                let parent = normalizeTypeName(inherited.type.description)
                addRelation(child: typeName, parent: parent)
            }
        }
        return .skipChildren
    }

    override func visit(_ node: EnumDeclSyntax) -> SyntaxVisitorContinueKind {
        let typeName = node.name.text
        if let clause = node.inheritanceClause {
            for inherited in clause.inheritedTypes {
                let parent = normalizeTypeName(inherited.type.description)
                addRelation(child: typeName, parent: parent)
            }
        }
        return .skipChildren
    }

    override func visit(_ node: ExtensionDeclSyntax) -> SyntaxVisitorContinueKind {
        guard let childName = extractBaseTypeName(from: node.extendedType) else {
            return .skipChildren
        }
        if let clause = node.inheritanceClause {
            for inherited in clause.inheritedTypes {
                let parent = normalizeTypeName(inherited.type.description)
                addRelation(child: childName, parent: parent)
            }
        }
        return .skipChildren
    }
}

// MARK: - Reachability
private func computeReachableTypes(parentsByType: [String: Set<String>], targets: Set<String>) -> Set<String> {
    var memo: [String: Bool] = [:]
    var visiting: Set<String> = []

    func dfs(_ type: String) -> Bool {
        if let cached = memo[type] { return cached }
        if targets.contains(type) { memo[type] = true; return true }
        if visiting.contains(type) { memo[type] = false; return false } // цикл
        visiting.insert(type)
        defer { visiting.remove(type) }

        for parent in parentsByType[type] ?? [] {
            if targets.contains(parent) || dfs(parent) {
                memo[type] = true
                return true
            }
        }
        memo[type] = false
        return false
    }

    var result: Set<String> = []
    for type in parentsByType.keys {
        if dfs(type) {
            result.insert(type)
        }
    }
    return result
}

// MARK: - Entry
let args = CommandLine.arguments
guard args.count == 3 else {
    fatalError("Usage: <exec> <srcRoot> <outputFile>")
}

let srcRoot = URL(fileURLWithPath: args[1])
let output  = URL(fileURLWithPath: args[2])

var globalRelations: [String: Set<String>] = [:]

if let enumerator = FileManager.default.enumerator(
    at: srcRoot,
    includingPropertiesForKeys: nil
) {
    for case let fileURL as URL in enumerator {
        guard fileURL.pathExtension == "swift" else { continue }

        let source = try String(contentsOf: fileURL)
        let tree = Parser.parse(source: source)

        let visitor = RelationCollectorVisitor(viewMode: .all)
        visitor.walk(tree)

        // Мержим отношения между файлами
        for (child, parents) in visitor.parentsByType {
            var set = globalRelations[child] ?? []
            set.formUnion(parents)
            globalRelations[child] = set
        }
    }
}

// Вычисляем достижимость до целевых базовых типов/протоколов
let componentTargets: Set<String> = ["TEComponent2D"]
let viewTargets: Set<String> = ["TEView2D"]

let foundComponents = computeReachableTypes(parentsByType: globalRelations, targets: componentTargets)
let foundViews = computeReachableTypes(parentsByType: globalRelations, targets: viewTargets)

let uniqueComponents = Array(foundComponents).sorted()
let uniqueViews = Array(foundViews).sorted()

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
