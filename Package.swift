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
            url: "https://github.com/synapseslab/bluegps-ios-sdk/raw/1.0.98/xcframework.zip",
            checksum: "0c6573009ea0e1baa0c7f94a79a32f836bbda1b6bb8b393f43c5ae1469829caa"
        ),
    ]
)
