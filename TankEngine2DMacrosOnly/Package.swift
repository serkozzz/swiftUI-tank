// swift-tools-version: 6.2
import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "TankEngine2DMacrosOnly",
    platforms: [
        .macOS(.v14)
    ],

    products: [
        // Клиент импортирует только интерфейс
        .library(
            name: "TankEngine2DMacroInterfaces",
            targets: ["TankEngine2DMacroInterfaces"]
        ),

        // SwiftPM CLI должен видеть реализацию как library product
        .library(
            name: "TankEngine2DMacros",
            targets: ["TankEngine2DMacros"]
        ),

        // Build tool plugin (не влияет на макросы)
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
        .macro(
            name: "TankEngine2DMacros",
            dependencies: [
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax")
            ],
            path: "Sources/EngineMacros/Macros"
        ),

        .target(
            name: "TankEngine2DMacroInterfaces",
            dependencies: ["TankEngine2DMacros"],
            path: "Sources/MacroInterfaces"
        ),

        .executableTarget(
            name: "TEComponentScannerExec",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax")
            ],
            path: "Sources/EngineMacros/Plugin/TEComponentScannerExec"
        ),

        .plugin(
            name: "TEComponentScanner",
            capability: .buildTool(),
            dependencies: ["TEComponentScannerExec"],
            path: "Sources/EngineMacros/Plugin/TEComponentScanner"
        )
    ]
)
