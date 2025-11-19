// swift-tools-version: 6.2
import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "TankEngine2DMacrosOnly",
    platforms: [
        .iOS(.v15),
        .macOS(.v14)
    ],

    products: [
        .library(
            name: "TankEngine2DMacros",
            targets: ["TankEngine2DMacros"]
        ),
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

        // MARK: — Макросы
        .macro(
            name: "TankEngine2DMacros",
            dependencies: [
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax")
            ],
            path: "Sources/EngineMacros/TankEngine2DMacros"
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
