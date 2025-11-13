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
            targets: ["TankEngine2D"]
        ),
    ],
    dependencies: [
        // правильная версия SwiftSyntax для Xcode 16.2
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "602.0.0"),
    ],
    targets: [
        // ObjC Target
        .target(
            name: "SafeKVC",
            path: "Sources/ObjC",
            publicHeadersPath: "."
        ),

        // Макросы (изолированные)
        .macro(
            name: "TankEngine2DMacros",
            dependencies: [
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax")
            ],
            path: "Sources/TankEngine2DMacros"
        ),

        // Основная библиотека движка (не импортирует SwiftSyntax напрямую)
        .target(
            name: "TankEngine2D",
            dependencies: [
                "SafeKVC",
                "TankEngine2DMacros"
            ],
            path: "Sources/TankEngine2D"
        ),

        .testTarget(
            name: "UnitTests",
            dependencies: ["TankEngine2D"],
            path: "Sources/UnitTests"
        ),
    ]
)

