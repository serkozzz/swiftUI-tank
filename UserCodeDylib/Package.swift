// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "UserCodeDylib",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "UserCodeDylib",
            type: .dynamic,
            targets: ["UserCodeDylib"]
        ),
    ],
    dependencies: [
        .package(path: "../TankEngine2D")
    ],
    targets: [
        .target(
            name: "UserCodeDylib",
            dependencies: [
                .product(name: "TankEngine2DDynamic", package: "TankEngine2D")
            ],
            swiftSettings: [
                .unsafeFlags(["-Xlinker", "-rpath", "-Xlinker", "@loader_path/../Frameworks"]),
                .unsafeFlags(["-Xlinker", "-rpath", "-Xlinker", "@executable_path/../Frameworks"])
            ]
        ),
    ],

)
