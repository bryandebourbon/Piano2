// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "Piano2",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "Piano2",
            targets: ["Piano2"]
        ),
    ],
    targets: [
        .target(
            name: "Piano2",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "Piano2Tests",
            dependencies: ["Piano2"]
        ),
    ]
)