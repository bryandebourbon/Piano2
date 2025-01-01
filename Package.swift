// swift-tools-version:5.7
import PackageDescription

let package = Package(
    name: "Piano2",
    platforms: [
        .iOS(.v13),
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
            dependencies: []
        ),
        .testTarget(
            name: "Piano2Tests",
            dependencies: ["Piano2"]
        ),
    ]
)