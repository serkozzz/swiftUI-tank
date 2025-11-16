import Foundation
import SwiftParser
import SwiftSyntax

let args = CommandLine.arguments
guard args.count == 3 else {
    fatalError("Usage: <exec> <srcRoot> <outputFile>")
}

let srcRoot = URL(fileURLWithPath: args[1])
let output  = URL(fileURLWithPath: args[2])

// Просто тест: если можем распарсить хотя бы один файл — всё работает
var found = [String]()

if let enumerator = FileManager.default.enumerator(
    at: srcRoot,
    includingPropertiesForKeys: nil
) {
    for case let fileURL as URL in enumerator {
        guard fileURL.pathExtension == "swift" else { continue }

        let source = try String(contentsOf: fileURL)
        _ = Parser.parse(source: source)

        found.append(fileURL.lastPathComponent)
    }
}

let text = """
// AUTO-GENERATED
Found files: \(found)
"""

try text.write(to: output, atomically: true, encoding: .utf8)
