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
        .library(
            name: "TankEngine2D",
            type: .static,
            targets: ["TankEngine2D"]
        ),
        
        // MARK: — DYNAMIC LIB (для Editor + UserCodeDylib)
        .library(
            name: "TankEngine2DDynamic",
            type: .dynamic,
            targets: ["TankEngine2DDynamicTarget"]
        ),
        
        // ВАЖНО: плагин тоже нужно экспортировать, чтобы проект пользователя мог его использовать
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
        // ObjC Target
        .target(
            name: "SafeKVC",
            path: "Sources/ObjC",
            publicHeadersPath: "."
        ),

        // Макросы
        .macro(
            name: "TankEngine2DMacros",
            dependencies: [
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax")
            ],
            path: "EngineMacros/Macros"
        ),

        // Основная библиотека движка
        .target(
            name: "TankEngine2D",
            dependencies: [
                "SafeKVC",
                "TankEngine2DMacros"
            ],
            path: "Sources/TankEngine2D",
            swiftSettings: [
              .define("TE2D_SPM")
            ]
        ),
        
        
        // MARK: — Dynamic wrapper target FIX for Xcode/SwiftPM
        .target(
            name: "TankEngine2DDynamicTarget",
            dependencies: ["TankEngine2D"],
            path: "Sources/DynamicWrapper" // может быть пустой каталог
        ),
        
        .plugin(
            name: "TEComponentScanner",
            capability: .buildTool(),
            dependencies: ["TEComponentScannerExec"],
            path: "EngineMacros/Plugin/TEComponentScanner"
        ),
        .executableTarget(
            name: "TEComponentScannerExec",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftParser", package: "swift-syntax"),
            ],
            path: "EngineMacros/Plugin/TEComponentScannerExec"
        ),


        .testTarget(
            name: "UnitTests",
            dependencies: ["TankEngine2D"],
            path: "Sources/UnitTests"
        ),
        
    ]
)
