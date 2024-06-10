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
            url: "https://github.com/synapseslab/bluegps-ios-sdk/raw/1.0.95/xcframework.zip",
            checksum: "45915b527e7264e9abe9a911b228b868b4268562180eacbc9b8d6ee4d6a70fdf"
        ),
    ]
)
