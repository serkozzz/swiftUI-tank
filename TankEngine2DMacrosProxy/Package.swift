// swift-tools-version: 6.2
import PackageDescription
import CompilerPluginSupport

let package = Package(
    name: "TankEngine2DMacros",
    platforms: [
        .iOS(.v15),
        .macOS(.v14)
    ],
    products: [
        .macro(
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

        // MARK: — Macro target
        .macro(
            name: "TankEngine2DMacros",
            dependencies: [
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax")
            ],
            path: "../TankEngine2D/EngineMacros/TankEngine2DMacros"
        ),

        // MARK: — Build tool plugin
        .plugin(
            name: "TEComponentScanner",
            capability: .buildTool(),
            dependencies: ["TEComponentScannerExec"],
            path: "../TankEngine2D/EngineMacros/TankEngine2DPlugin/TEComponentScanner"
        ),

        // MARK: — Executable used by the plugin
        .executableTarget(
            name: "TEComponentScannerExec",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax")
            ],
            path: "../TankEngine2D/EngineMacros/TankEngine2DPlugin/TEComponentScannerExec"
        )
    ]
)
