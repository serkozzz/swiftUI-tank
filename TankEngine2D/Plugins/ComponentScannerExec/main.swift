import Foundation
import SwiftParser
import SwiftSyntax

// MARK: - Visitor
final class ComponentVisitor: SyntaxVisitor {
    var found: [String] = []

    override func visit(_ node: ClassDeclSyntax) -> SyntaxVisitorContinueKind {
        process(node)
        return .skipChildren
    }

    override func visit(_ node: StructDeclSyntax) -> SyntaxVisitorContinueKind {
        process(node)
        return .skipChildren
    }

    private func process(_ node: ClassDeclSyntax) {
        let name = node.name.text

        if inheritsFromComponent(node.inheritanceClause) {
            found.append(name)
        }
    }

    private func process(_ node: StructDeclSyntax) {
        let name = node.name.text

        if inheritsFromComponent(node.inheritanceClause) {
            found.append(name)
        }
    }

    private func inheritsFromComponent(_ clause: InheritanceClauseSyntax?) -> Bool {
        guard let clause else { return false }

        for inherited in clause.inheritedTypes {
            let base = inherited.type.description
                .trimmingCharacters(in: .whitespacesAndNewlines)

            if base == "TEComponent2D" {
                return true
            }
        }
        return false
    }
}

// MARK: - Entry
let args = CommandLine.arguments
guard args.count == 3 else {
    fatalError("Usage: <exec> <srcRoot> <outputFile>")
}

let srcRoot = URL(fileURLWithPath: args[1])
let output  = URL(fileURLWithPath: args[2])

var allComponents = [String]()

if let enumerator = FileManager.default.enumerator(
    at: srcRoot,
    includingPropertiesForKeys: nil
) {
    for case let fileURL as URL in enumerator {
        guard fileURL.pathExtension == "swift" else { continue }

        let source = try String(contentsOf: fileURL)
        let tree = Parser.parse(source: source)

        let visitor = ComponentVisitor(viewMode: .all)
        visitor.walk(tree)

        allComponents.append(contentsOf: visitor.found)
    }
}

let unique = Array(Set(allComponents)).sorted()

// MARK: - Генерация итогового файла
let dictEntries = unique.map { #"String(reflecting: \#($0).self): \#($0).self"# }
let text = """
// AUTO-GENERATED — DO NOT EDIT
// Found components: \(unique.count)

import TankEngine2D

@MainActor
public enum TEAutoDetectedComponents2D {
    public static var components: [String: TEComponent2D.Type] = [
        \(dictEntries.joined(separator: ",\n        "))
    ]
}
"""

try text.write(to: output, atomically: true, encoding: .utf8)
