// swift-tools-version:5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "dit",
    platforms: [.macOS(SupportedPlatform.MacOSVersion.v11)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", .upToNextMinor(from: "0.4.3")),
        .package(url: "https://github.com/fcanas/FFCParserCombinator", .upToNextMajor(from: "1.0.1"))
    ],
    targets: [
        .target(name: "libDit",
                dependencies: [
                    .product(name: "FFCParserCombinator", package: "FFCParserCombinator")
                ]),
        .executableTarget(
            name: "dit",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "libDit"
            ]),
        .testTarget(
            name: "ditTests",
            dependencies: ["libDit"]),
    ]
)
