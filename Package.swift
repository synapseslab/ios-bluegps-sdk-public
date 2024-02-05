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
            checksum: "3c18055538f45ae5d630461f79b55a430fbaa5e6cf7b53eefa14bca4e6b43d31"
        ),
    ]
)
