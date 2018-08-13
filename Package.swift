// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "VGASimulator",
    products: [
        .library(name: "VGASimulatorCore", targets: ["VGASimulatorCore"]),
        .library(name: "VGASimulatorKit", targets: ["VGASimulatorKit"]),
        .executable(name: "VGASimulator", targets: ["VGASimulatorCommandLine"]),
    ],
    dependencies: [
        .package(path: "../LoggerKit"),
        .package(path: "../CommandLineKit"),
        .package(path: "../FoundationKit"),
        .package(url: "https://github.com/kelvin13/maxpng.git", .branch("master"))
    ],
    targets: [
        .target(name: "VGASimulatorCore",
                path: "VGASimulatorCore"),
        .target(name: "VGASimulatorKit",
                dependencies: ["VGASimulatorCore"],
                path: "VGASimulatorKit",
                exclude: ["Legacy"]),
        .target(name: "VGASimulatorCommandLine",
                dependencies: ["LoggerKit", "CommandLineKit", "VGASimulatorKit", "FoundationKit", "MaxPNG"],
                path: "VGASimulatorCommandLine"),
    ]
)
