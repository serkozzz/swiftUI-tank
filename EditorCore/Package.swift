// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "EditorCore",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "EditorCore",
            type: .static,   // ← статическая библиотека
            targets: ["EditorCore"]
        )
    ],
    dependencies: [
        .package(path: "../TankEngine2D")   // движок как SPM-зависимость
    ],
    targets: [
        .target(
            name: "EditorCore",
            dependencies: [
                .product(name: "TankEngine2D", package: "TankEngine2D")
            ]
            // никаких rpath НЕ нужно для статической библиотеки!
        ),

//        .testTarget(
//            name: "EditorCoreTests",
//            dependencies: ["EditorCore"]
//        )
    ]
)
