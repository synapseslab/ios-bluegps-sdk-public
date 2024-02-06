// swift-tools-version: 5.9

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "bluegps-ios-sdk",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "bluegps-ios-sdk",
            targets: ["bluegps-ios-sdk"]),
    ],
    targets: [
        .binaryTarget(
            name: "bluegps-ios-sdk",
            url: "https://github.com/synapseslab/bluegps-ios-sdk/raw/main/xcframework.zip",
            checksum: "81ab7eef7b59334b7fc530ac48f44a8258a9ec15b9860dfd9f277bb37c4e9e6e"
        ),
    ]
)
