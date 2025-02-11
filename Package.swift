// swift-tools-version: 5.9

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "ios-bluegps-sdk-public",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "ios-bluegps-sdk-public",
            targets: ["ios-bluegps-sdk-public"]),
    ],
    targets: [
        .binaryTarget(
            name: "ios-bluegps-sdk-public",
            url: "https://github.com/synapseslab/bluegps-ios-sdk/raw/2.0.108/xcframework.zip",
            checksum: "8b3897af868b7a21b0f551f41ada657847a668e7ac5156d1dbc177b786b7b58a"
        ),
    ]
)
