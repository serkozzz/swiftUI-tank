// swift-tools-version: 6.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TankEngine2D",
    platforms: [
            .iOS(.v13), // Минимальная версия iOS (подстрой под свои нужды)
            .macOS(.v10_15)
        ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "TankEngine2D",
            targets: ["TankEngine2D"]),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "TankEngine2D",
            path: "Sources/TankEngine2D") // Явно указываем путь (хотя по умолчанию тот же),

    ]
)
