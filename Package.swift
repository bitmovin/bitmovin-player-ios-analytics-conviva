// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BitmovinConvivaAnalytics",
    platforms: [
        .iOS(.v15),
        .tvOS(.v15)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "BitmovinConvivaAnalytics",
            targets: ["BitmovinConvivaAnalytics"]),
    ],
    dependencies: [
        .package(url: "https://github.com/Conviva/conviva-ios-sdk-spm.git", exact: "4.0.40"),
        .package(url: "https://github.com/bitmovin/player-ios-core.git", from: "3.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "BitmovinConvivaAnalytics",
            path: "BitmovinConvivaAnalytics"),
        .testTarget(
            name: "BitmovinConvivaAnalyticsTests",
            dependencies: ["BitmovinConvivaAnalytics"]),
    ]
)
