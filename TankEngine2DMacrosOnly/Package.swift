// swift-tools-version: 6.2
import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "TankEngine2DMacrosOnly",
    platforms: [
        .macOS(.v14)
    ],

    products: [

        // 1) Клиент импортирует ТОЛЬКО интерфейсы макросов.
        .library(
            name: "TankEngine2DMacroInterfaces",
            targets: ["TankEngine2DMacroInterfaces"]
        ),

        // 2) SwiftPM CLI требует экспортировать macro target как library product,
        //    иначе макросы НЕ активируются при runtime-компиляции.
        .library(
            name: "TankEngine2DMacros",
            targets: ["TankEngine2DMacros"]
        ),

        // 3) Build tool plugin (если нужен для работы движка/сканера)
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

        // MARK: — Macro implementation (compiler plugin)
        .macro(
            name: "TankEngine2DMacros",
            dependencies: [
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax")
            ],
            path: "Sources/EngineMacros/TankEngine2DMacros"
        ),

        // MARK: — Macro interface (external declarations)
        .target(
            name: "TankEngine2DMacroInterfaces",
            dependencies: [
                // внутренний линк на реализацию
                "TankEngine2DMacros"
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

        // MARK: — Build tool plugin definition
        .plugin(
            name: "TEComponentScanner",
            capability: .buildTool(),
            dependencies: ["TEComponentScannerExec"],
            path: "Sources/EngineMacros/TankEngine2DPlugin/TEComponentScanner"
        )
    ]
)
