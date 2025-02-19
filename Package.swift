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
            url: "https://github.com/synapseslab/bluegps-ios-sdk/raw/2.0.109/xcframework.zip",
            checksum: "1ba725572c33885883ccb4ff1e5aa41d959d3b239631d2607a90400ff5c83f3c"
        ),
    ]
)
