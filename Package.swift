// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "VGASimulatorKit",
    platforms: [
        .macOS(.v10_12),
    ],
    products: [
        .executable(
            name: "VGASimulator",
            targets: ["VGASimulator"]
        ),
        .library(
            name: "VGASimulatorKit",
            targets: ["VGASimulatorKit"]
        )
    ],
    dependencies: [
        .package(url: "git@github.com:pvieito/LoggerKit.git", .branch("master")),
        .package(url: "git@github.com:pvieito/FoundationKit.git", .branch("master")),
        .package(url: "git@github.com:pvieito/CoreGraphicsKit.git", .branch("master")),
        .package(url: "https://github.com/twostraws/SwiftGD.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.1"),
    ],
    targets: [
        .target(
            name: "VGASimulator",
            dependencies: ["VGASimulatorKit", "LoggerKit", "FoundationKit", .product(name: "ArgumentParser", package: "swift-argument-parser")],
            path: "VGASimulator"
        ),
        .target(
            name: "VGASimulatorKit",
            dependencies: ["VGASimulatorCore", "CoreGraphicsKit", "SwiftGD"],
            path: "VGASimulatorKit",
            swiftSettings: [
                .define("_NO_COREGRAPHICS")
            ]
        ),
        .target(
            name: "VGASimulatorCore",
            path: "VGASimulatorCore"
        ),
        .testTarget(
            name: "VGASimulatorKitTests",
            dependencies: ["VGASimulatorKit", "FoundationKit"]
        )
    ]
)
