// swift-tools-version: 6.2
import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "TankEngine2DMacrosOnly",
    platforms: [
        .macOS(.v14)
    ],

    products: [
        // Клиент импортирует только этот продукт
        .library(
            name: "TankEngine2DMacroInterfaces",
            targets: ["TankEngine2DMacroInterfaces"]
        ),

        // Build Tool Plugin
        .plugin(
            name: "TEComponentScanner",
            targets: ["TEComponentScanner"]
        )
    ],

    dependencies: [
        .package(
            url: "https://github.com/swiftlang/swift-syntax.git",
            from: "602.0.0"
        )
    ],

    targets: [

        // MARK: — Macro implementation target (NOT exported as product)
        .macro(
            name: "TankEngine2DMacros",
            dependencies: [
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax")
            ],
            path: "Sources/EngineMacros/TankEngine2DMacros"
        ),

        // MARK: — Macro interface target (public declarations)
        .target(
            name: "TankEngine2DMacroInterfaces",
            dependencies: [
                "TankEngine2DMacros" // internal dependency — OK
            ],
            path: "Sources/MacroInterfaces"
        ),

        // MARK: — Executable for the build tool plugin
        .executableTarget(
            name: "TEComponentScannerExec",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax")
            ],
            path: "Sources/EngineMacros/TankEngine2DPlugin/TEComponentScannerExec"
        ),

        // MARK: — Build tool plugin
        .plugin(
            name: "TEComponentScanner",
            capability: .buildTool(),
            dependencies: ["TEComponentScannerExec"],
            path: "Sources/EngineMacros/TankEngine2DPlugin/TEComponentScanner"
        )
    ]
)
