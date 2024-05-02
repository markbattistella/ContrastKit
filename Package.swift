// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "ContrastKit",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
        .macCatalyst(.v14),
        .tvOS(.v14),
        .watchOS(.v7),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "ContrastKit",
            targets: ["ContrastKit"]
        )
    ],
    targets: [
        .target(
            name: "ContrastKit",
            dependencies: [],
            path: "Sources"
        ),
        .testTarget(
            name: "ContrastKitTests",
            dependencies: ["ContrastKit"],
            path: "Tests"
        )
    ]
)
