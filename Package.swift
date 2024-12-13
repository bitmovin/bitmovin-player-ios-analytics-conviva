// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "bitmovin-player-ios-analytics-conviva",
    platforms: [.iOS(.v14), .tvOS(.v14),],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "BitmovinConvivaAnalytics",
            targets: ["BitmovinConvivaAnalytics"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/bitmovin/player-ios.git", from: "3.75.0"),
        .package(url: "https://github.com/Conviva/conviva-ios-sdk-spm.git", from: "4.0.51"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "BitmovinConvivaAnalytics",
            dependencies: [
                .product(name: "ConvivaSDK", package: "conviva-ios-sdk-spm"),
                .product(name: "BitmovinPlayer", package: "player-ios"),
            ],
            path: "BitmovinConvivaAnalytics"
        ),
    ]
)
