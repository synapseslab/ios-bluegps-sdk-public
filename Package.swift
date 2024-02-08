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
            checksum: "b57510e603e75b14ae472099bcae308a5ebf4976c5efd6a15b2d62354c545ebb"
        ),
    ]
)
