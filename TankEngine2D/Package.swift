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
            targets: ["TankEngine2D"]),
    ],
    targets: [
        .target(name: "TankEngine2D", path: "Sources/TankEngine2D"), // Явно указываем путь (хотя по умолчанию тот же),
        .testTarget(name: "UnitTests", dependencies: ["TankEngine2D"], path: "Sources/UnitTests"),
    ]
)
