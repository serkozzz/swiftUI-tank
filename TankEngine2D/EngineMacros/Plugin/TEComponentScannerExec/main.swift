import Foundation
import SwiftParser
import SwiftSyntax

// MARK: - Helpers
private func normalizeTypeName(_ raw: String) -> String {
    let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return trimmed }
    let withoutGenerics: String
    if let angleIndex = trimmed.firstIndex(of: "<") {
        withoutGenerics = String(trimmed[..<angleIndex])
    } else {
        withoutGenerics = trimmed
    }
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
    private(set) var parentsByType: [String: Set<String>] = [:]
    private(set) var declaredIn: [String: URL] = [:]

    private let fileURL: URL

    init(fileURL: URL, viewMode: SyntaxTreeViewMode = .all) {
        self.fileURL = fileURL
        super.init(viewMode: viewMode)
    }

    private func addRelation(child: String, parent: String) {
        guard !child.isEmpty, !parent.isEmpty else { return }
        parentsByType[child, default: []].insert(parent)
    }

    private func recordDeclaration(of typeName: String) {
        guard !typeName.isEmpty else { return }
        if declaredIn[typeName] == nil {
            declaredIn[typeName] = fileURL
        }
    }

    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        let typeName = node.name.text
        recordDeclaration(of: typeName)
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
        recordDeclaration(of: typeName)
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
        recordDeclaration(of: typeName)
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
        if visiting.contains(type) { memo[type] = false; return false }
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
    fputs("error: Usage: <exec> <srcRoot> <outputFile>\n", stderr)
    exit(1)
}

let srcRoot = URL(fileURLWithPath: args[1])
let output  = URL(fileURLWithPath: args[2])

var globalRelations: [String: Set<String>] = [:]
var declaredInGlobal: [String: URL] = [:]

if let enumerator = FileManager.default.enumerator(
    at: srcRoot,
    includingPropertiesForKeys: nil
) {
    for case let fileURL as URL in enumerator {
        guard fileURL.pathExtension == "swift" else { continue }

        let source = try String(contentsOf: fileURL)
        let tree = Parser.parse(source: source)

        let visitor = RelationCollectorVisitor(fileURL: fileURL, viewMode: .all)
        visitor.walk(tree)

        for (child, parents) in visitor.parentsByType {
            var set = globalRelations[child] ?? []
            set.formUnion(parents)
            globalRelations[child] = set
        }
        for (typeName, url) in visitor.declaredIn {
            if declaredInGlobal[typeName] == nil {
                declaredInGlobal[typeName] = url
            }
        }
    }
}

let componentTargets: Set<String> = ["TEComponent2D"]
let viewTargets: Set<String> = ["TEView2D"]

let foundComponents = computeReachableTypes(parentsByType: globalRelations, targets: componentTargets)
let foundViews = computeReachableTypes(parentsByType: globalRelations, targets: viewTargets)

// Собираем диагностические сообщения
var diagnostics: [(file: URL, line: Int, column: Int, message: String)] = []

@MainActor
func checkFileNameMatchesType(_ typeNames: Set<String>, kind: String) {
    for typeName in typeNames {
        guard let url = declaredInGlobal[typeName] else {
            // Возможно, тип из внешнего модуля — пропускаем
            continue
        }
        let fileBase = url.deletingPathExtension().lastPathComponent
        if fileBase != typeName {
            let msg = "[\(kind)] type '\(typeName)' is declared in '\(url.lastPathComponent)', but for TEComponent2D and TEView2D file name must equal type name. File name must be '\(typeName).swift'"
            diagnostics.append((file: url, line: 1, column: 1, message: msg))
        }
    }
}

checkFileNameMatchesType(foundComponents.subtracting(componentTargets), kind: "Component")
checkFileNameMatchesType(foundViews.subtracting(viewTargets), kind: "View")

// Если есть ошибки — печатаем в stderr в формате "<path>:<line>:<column>: error: <message>"
if !diagnostics.isEmpty {
    for d in diagnostics {
        fputs("\(d.file.path):\(d.line):\(d.column): error: \(d.message)\n", stderr)
    }
    exit(1)
}

let uniqueComponents = Array(foundComponents).sorted()
let uniqueViews = Array(foundViews).sorted()

let componentEntries = uniqueComponents.map { #"String(reflecting: \#($0).self): \#($0).self"# }
let viewEntries = uniqueViews.map { #"String(reflecting: \#($0).self): \#($0).self"# }

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
