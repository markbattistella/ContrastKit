// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "ContrastKit",
  platforms: [
    .iOS(.v17),
    .macOS(.v14),
    .macCatalyst(.v17),
    .tvOS(.v17),
    .watchOS(.v10),
    .visionOS(.v1),
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
      path: "Sources",
      swiftSettings: [
        .swiftLanguageMode(.v6)
      ]
    ),
    .testTarget(
      name: "ContrastKitTests",
      dependencies: ["ContrastKit"],
      path: "Tests",
      swiftSettings: [
        .swiftLanguageMode(.v6)
      ]
    ),
  ],
  swiftLanguageModes: [.v6]
)
