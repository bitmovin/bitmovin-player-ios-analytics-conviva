// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "bitmovin-player-ios-analytics-conviva",
    platforms: [.iOS(.v14), .tvOS(.v14)],
    products: [
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
        .target(
            name: "BitmovinConvivaAnalytics",
            dependencies: [
                .product(name: "ConvivaSDK", package: "conviva-ios-sdk-spm"),
                .product(name: "BitmovinPlayer", package: "player-ios"),
            ],
            // The source folder also contains an `Assets/` Info.plist used by the
            // CocoaPods build; scope the SPM target to the Swift sources only.
            path: "BitmovinConvivaAnalytics",
            exclude: ["Assets"],
            sources: ["Classes"]
        ),
    ]
)
