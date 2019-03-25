// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "VGASimulator",
    products: [
        .executable(
            name: "VGASimulator",
            targets: ["VGASimulatorCommandLine"]
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
            name: "VGASimulatorCommandLine",
            dependencies: ["VGASimulatorKit", "LoggerKit", "CommandLineKit", "FoundationKit", "CoreGraphicsKit"],
            path: "VGASimulatorCommandLine"
        ),
        .target(
            name: "VGASimulatorKit",
            dependencies: ["VGASimulatorCore"],
            path: "VGASimulatorKit"
        ),
        .target(
            name: "VGASimulatorCore",
            path: "VGASimulatorCore"
        )
    ]
)
