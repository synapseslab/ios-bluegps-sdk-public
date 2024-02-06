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
            checksum: "4196e5aed9657b9b397fd53a66b56e603c7f26235413c39d62b22b930ea876ab"
        ),
    ]
)
