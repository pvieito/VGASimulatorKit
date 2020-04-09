// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "VGASimulatorKit",
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
        .package(url: "https://github.com/pvieito/LoggerKit.git", .branch("master")),
        .package(url: "https://github.com/pvieito/FoundationKit.git", .branch("master")),
        .package(url: "https://github.com/pvieito/CoreGraphicsKit.git", .branch("master")),
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "0.0.1")),
    ],
    targets: [
        .target(
            name: "VGASimulator",
            dependencies: ["VGASimulatorKit", "LoggerKit", "FoundationKit", "CoreGraphicsKit", .product(name: "ArgumentParser", package: "swift-argument-parser")],
            path: "VGASimulator"
        ),
        .target(
            name: "VGASimulatorKit",
            dependencies: ["VGASimulatorCore"],
            path: "VGASimulatorKit"
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
