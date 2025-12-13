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

// MARK: - Property Collector for Component Refs
private struct PropertyRefInfo {
    let name: String
    let kind: RefKind
    enum RefKind {
        case direct
        case optional
        case published
        case publishedOptional
    }
}

private final class ComponentPropertyCollector: SyntaxVisitor {
    private(set) var refProperties: [PropertyRefInfo] = []
    private let componentTypeNames: Set<String>

    init(componentTypeNames: Set<String>) {
        self.componentTypeNames = componentTypeNames
        super.init(viewMode: .all)
    }

    override func visit(_ node: VariableDeclSyntax) -> SyntaxVisitorContinueKind {
        // Ignore static and computed properties
        guard !node.modifiers.contains(where: { $0.name.text == "static" }) else { return .skipChildren }
        guard node.bindings.count == 1 else { return .skipChildren }
        let binding = node.bindings.first!
        guard binding.accessorBlock == nil else { return .skipChildren } // computed

        let rawType = binding.typeAnnotation?.type.trimmedDescription ?? ""
        let propName = binding.pattern.description.trimmingCharacters(in: .whitespacesAndNewlines)
        if propName.isEmpty { return .skipChildren }

        // Property wrappers (Published, etc)
        let wrappers: [String] = node.attributes.compactMap { attr in
            if let custom = attr.as(AttributeSyntax.self) {
                return custom.attributeName.trimmedDescription
            }
            return nil
        }

        func isComponentType(_ typeStr: String) -> Bool {
            let normalized = typeStr
                .replacingOccurrences(of: "?", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return componentTypeNames.contains(normalized)
        }

        func isOptionalComponent(_ typeStr: String) -> Bool {
            let trimmed = typeStr.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.hasPrefix("Optional<") {
                let baseType = trimmed
                    .replacingOccurrences(of: "Optional<", with: "")
                    .replacingOccurrences(of: ">", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                return isComponentType(baseType)
            }
            if trimmed.hasSuffix("?") {
                let baseType = trimmed
                    .replacingOccurrences(of: "?", with: "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                return isComponentType(baseType)
            }
            return false
        }

        // --- Главная логика (исправленная для property wrapper'а) ---
        if wrappers.contains("Published") {
            // @Published var x: TEComponent2D или наследник
            if isComponentType(rawType) {
                refProperties.append(.init(name: propName, kind: .published))
            } else if isOptionalComponent(rawType) {
                refProperties.append(.init(name: propName, kind: .publishedOptional))
            }
        } else {
            // Просто var x: TEComponent2D или наследник
            if isComponentType(rawType) {
                refProperties.append(.init(name: propName, kind: .direct))
            } else if isOptionalComponent(rawType) {
                refProperties.append(.init(name: propName, kind: .optional))
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
var syntaxTreesByType: [String: (URL, SourceFileSyntax)] = [:]

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
                syntaxTreesByType[typeName] = (fileURL, tree)
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

let componentEntries = uniqueComponents.map { #"TEComponentsRegister2D.shared.getKeyFor(\#($0).self): \#($0).self"# }
let viewEntries = uniqueViews.map { #"TEViewsRegister2D.shared.getKeyFor(\#($0).self): \#($0).self"# }

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

let allComponentTypesComment = "// Components: \(uniqueComponents.joined(separator: ", "))\n"

let registratorText = """
\(allComponentTypesComment)// AUTO-GENERATED — DO NOT EDIT
// Found components: \(uniqueComponents.count)
// Found views: \(uniqueViews.count)

import TankEngine2D

@MainActor
public final class TEAutoRegistrator2D: TEAutoRegistratorProtocol {
    public let components: [String: TEComponent2D.Type] = \(componentsDictLiteral)
    public let views: [String: any TEView2D.Type] = \(viewsDictLiteral)
}
"""

try registratorText.write(to: output, atomically: true, encoding: .utf8)

// ---- GENERATE OVERRIDES FOR allTEComponentRefs ----
let overrideHeader = """
// AUTO-GENERATED — DO NOT EDIT
// Collects references to other TEComponent2D from component properties

import TankEngine2D

"""

let overrideDir = output.deletingLastPathComponent().appendingPathComponent("AutoComponentRefs")
try? FileManager.default.createDirectory(at: overrideDir, withIntermediateDirectories: true)

for typeName in uniqueComponents where typeName != "TEComponent2D" {
    guard let (declFile, tree) = syntaxTreesByType[typeName] else { continue }

    // Найти объявление класса
    var foundClass: ClassDeclSyntax?
    for statement in tree.statements {
        if let cls = statement.item.as(ClassDeclSyntax.self), cls.name.text == typeName {
            foundClass = cls
            break
        }
    }
    guard let classDecl = foundClass else { continue }

    // Собираем все имена типов наследников TEComponent2D (включая сам TEComponent2D)
    let allComponentTypes = uniqueComponents

    // Собрать свойства, которые надо учитывать
    let propCollector = ComponentPropertyCollector(componentTypeNames: Set(allComponentTypes))
    propCollector.walk(classDecl.memberBlock)

    // Генерируем тело функции
    var lines: [String] = []
    lines.append("public override func allTEComponentRefs() -> [String: UUID?] {")
    lines.append("    var dict = super.allTEComponentRefs()")

    for property in propCollector.refProperties {
        let name = property.name
        switch property.kind {
        case .direct:
            lines.append("    dict[\"\(name)\"] = self.\(name).id")
        case .optional:
            lines.append("    dict[\"\(name)\"] = self.\(name)?.id")
        case .published:
            lines.append("    dict[\"\(name)\"] = self.\(name).id")
        case .publishedOptional:
            lines.append("    dict[\"\(name)\"] = self.\(name)?.id")
        }
    }

    lines.append("    return dict")
    lines.append("}")

    let fileBody =
    """
    \(overrideHeader)

    extension \(typeName) {
    \(lines.joined(separator: "\n"))
    }
    """

    let outFile = overrideDir.appendingPathComponent("\(typeName)+AutoComponentRefs.swift")
    try fileBody.write(to: outFile, atomically: true, encoding: .utf8)
}
