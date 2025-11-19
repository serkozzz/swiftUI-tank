// swift-tools-version: 6.2
import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "TankEngine2D",
    platforms: [
        .iOS(.v15),
        .macOS(.v14)
    ],
    products: [

        // MARK: — STATIC LIB (для обычных приложений)
        .library(
            name: "TankEngine2D",
            type: .static,
            targets: ["TankEngine2D"]
        ),

        // MARK: — Scanner plugin
        .plugin(
            name: "TEComponentScanner",
            targets: ["TEComponentScanner"]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/swiftlang/swift-syntax.git",
            from: "602.0.0"
        ),
    ],

    targets: [

        // MARK: — ObjC helpers
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
            path: "Sources/TankEngine2DMacros"
        ),

        // MARK: — Main engine (base target)
        .target(
            name: "TankEngine2D",
            dependencies: [
                "SafeKVC",
                "TankEngine2DMacros"
            ],
            path: "Sources/TankEngine2D"
        ),

        // MARK: — Build tool plugin
        .plugin(
            name: "TEComponentScanner",
            capability: .buildTool(),
            dependencies: ["TEComponentScannerExec"],
            path: "Plugins/ComponentScanner"
        ),

        .executableTarget(
            name: "TEComponentScannerExec",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
            ],
            path: "Plugins/ComponentScannerExec"
        ),

        // MARK: — Tests
        .testTarget(
            name: "UnitTests",
            dependencies: ["TankEngine2D"],
            path: "Sources/UnitTests"
        ),
    ]
)
