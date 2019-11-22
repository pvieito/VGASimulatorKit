// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "VGASimulator",
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
        .package(path: "../LoggerKit"),
        .package(path: "../CommandLineKit"),
        .package(path: "../FoundationKit"),
        .package(path: "../CoreGraphicsKit")
    ],
    targets: [
        .target(
            name: "VGASimulator",
            dependencies: ["VGASimulatorKit", "LoggerKit", "CommandLineKit", "FoundationKit", "CoreGraphicsKit"],
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
