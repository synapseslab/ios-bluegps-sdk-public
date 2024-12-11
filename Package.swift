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
            url: "https://github.com/synapseslab/bluegps-ios-sdk/raw/1.0.100/xcframework.zip",
            checksum: "c437eb512ef8f01190104491b570842fd97a69eafbf6e1250e235c22d3a89a84"
        ),
    ]
)
