// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TankEngine2D",
    platforms: [
        .iOS(.v15),
        .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "TankEngine2D",
            targets: ["TankEngine2D"]
        ),
    ],
    targets: [
        // Clang (ObjC) target that exposes SafeKVC to Swift
        .target(
            name: "SafeKVC",
            path: "Sources/ObjC",
            publicHeadersPath: "."
        ),
        // Swift target depends on the ObjC target
        .target(
            name: "TankEngine2D",
            dependencies: ["SafeKVC"],
            path: "Sources/TankEngine2D"
        ),
        .testTarget(
            name: "UnitTests",
            dependencies: ["TankEngine2D"],
            path: "Sources/UnitTests"
        ),
    ]
)
