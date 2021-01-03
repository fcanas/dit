// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "dit",
    platforms: [.macOS(SupportedPlatform.MacOSVersion.v11)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "0.3.1")),
        .package(url: "https://github.com/fcanas/FFCParserCombinator", .upToNextMinor(from: "1.0.1"))
    ],
    targets: [
        .target(
            name: "dit",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "FFCParserCombinator", package: "FFCParserCombinator")
            ]),
        .testTarget(
            name: "ditTests",
            dependencies: ["dit"]),
    ]
)
