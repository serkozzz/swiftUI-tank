// swift-tools-version: 6.2
import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "TankEngine2DMacrosOnly",
    platforms: [
        .macOS(.v14)
    ],

    products: [
        // Продукт с реализациями макросов (plugin)
        .library(
            name: "TankEngine2DMacros",
            targets: ["TankEngine2DMacros"]
        ),
        // Новый продукт: обычная библиотека с интерфейсом (externalMacro объявления)
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

        // MARK: — Макросы (реализация)
        .macro(
            name: "TankEngine2DMacros",
            dependencies: [
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax")
            ],
            path: "Sources/EngineMacros/TankEngine2DMacros"
        ),

        // MARK: — Интерфейс макросов (объявления @attached … = #externalMacro)
        .target(
            name: "TankEngine2DMacroInterfaces",
            dependencies: [],
            path: "Sources/MacroInterfaces",
        ),

        // MARK: — Исполняемый файл плагина
        .executableTarget(
            name: "TEComponentScannerExec",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax")
            ],
            path: "Sources/EngineMacros/TankEngine2DPlugin/TEComponentScannerExec"
        ),

        // MARK: — Build Tool Plugin
        .plugin(
            name: "TEComponentScanner",
            capability: .buildTool(),
            dependencies: ["TEComponentScannerExec"],
            path: "Sources/EngineMacros/TankEngine2DPlugin/TEComponentScanner"
        )
    ]
)
