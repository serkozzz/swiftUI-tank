// swift-tools-version: 6.2

import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "TankEngine2D",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
        .macOS(.v14)
    ],
    products: [

        // MARK: — Static library for game projects
        .library(
            name: "TankEngine2D",
            type: .static,
            targets: ["TankEngine2D"]
        ),

        // MARK: — Build tool plugin (optional)
        .plugin(
            name: "TEComponentScanner",
            targets: ["TEComponentScanner"]
        )
    ],

    dependencies: [

        // 1) SwiftSyntax for plugin work
        .package(
            url: "https://github.com/swiftlang/swift-syntax.git",
            from: "602.0.0"
        ),
    ],

    targets: [

        // MARK: — Objective-C helper
        .target(
            name: "SafeKVC",
            path: "Sources/ObjC",
            publicHeadersPath: "."
        ),

        // MARK: — Macros
        .macro(
            name: "TankEngine2DMacros",
            dependencies: [
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax")
            ],
            path: "EngineMacros/TankEngine2DMacros"
        ),
        // MARK: — Main engine (STATIC LIB)
        .target(
            name: "TankEngine2D",
            dependencies: [
                "SafeKVC",
                // Автоматически подтягиваем макросы!
                .product(name: "TankEngine2DMacros", package: "TankEngine2DMacros")
            ],
            path: "Sources/TankEngine2D",
            exclude: []
        ),

        // MARK: — Build tool plugin (component scanner)
        .plugin(
            name: "TEComponentScanner",
            capability: .buildTool(),
            dependencies: ["TEComponentScannerExec"],
            path: "EngineMacros/TankEngine2DPlugin/TEComponentScanner"
        ),

        // MARK: — Scanner executable
        .executableTarget(
            name: "TEComponentScannerExec",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax")
            ],
            path: "EngineMacros/TankEngine2DPlugin/TEComponentScannerExec"
        ),

        // MARK: — Tests
        .testTarget(
            name: "UnitTests",
            dependencies: ["TankEngine2D"],
            path: "Sources/UnitTests"
        ),
    ]
)
