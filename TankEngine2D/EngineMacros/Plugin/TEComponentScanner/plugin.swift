import PackagePlugin
import Foundation

@main
struct TEComponentScanner: BuildToolPlugin {
    // MARK: SwiftPM
    func createBuildCommands(
        context: PluginContext,
        target: Target
    ) throws -> [Command] {

        return try Self.generateCommands(
            tool: context.tool(named: "TEComponentScannerExec"),
            sourceRoot: target.directoryURL,
            workDir: context.pluginWorkDirectoryURL
        )
    }
}

#if canImport(XcodeProjectPlugin)
import XcodeProjectPlugin

extension TEComponentScanner: XcodeBuildToolPlugin {
    // MARK: Xcode
    func createBuildCommands(
        context: XcodePluginContext,
        target: XcodeTarget
    ) throws -> [Command] {

        // ВАЖНО:
        // XcodeTarget не имеет directoryURL
        // Поэтому используем проект (ресурсы, Swift-код и всё остальное лежит в проекте)
        let projectRoot = context.xcodeProject.directoryURL

        return try Self.generateCommands(
            tool: context.tool(named: "TEComponentScannerExec"),
            sourceRoot: projectRoot,
            workDir: context.pluginWorkDirectoryURL
        )
    }
}
#endif

// MARK: Shared logic
extension TEComponentScanner {
    static func generateCommands(
        tool: PluginContext.Tool,
        sourceRoot: URL,
        workDir: URL
    ) throws -> [Command] {

        let output = workDir.appendingPathComponent("TEAutoRegistrator2D.generated.swift")
        print("🧩 TEComponentScanner output file:")
        print(output.path)
        
        return [
            .buildCommand(
                displayName: "Scanning TEComponent2D components",
                executable: tool.url,
                arguments: [
                    sourceRoot.path(),     // путь исходного проекта
                    output.path()          // куда писать файл
                ],
                outputFiles: [output]
            )
        ]
    }
}

