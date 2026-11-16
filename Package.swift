// swift-tools-version: 5.9

import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "ios-bluegps-sdk-public",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "ios-bluegps-sdk-public",
            targets: ["ios-bluegps-sdk-public"]),
    ],
    targets: [
        .binaryTarget(
            name: "ios-bluegps-sdk-public",
            url: "https://github.com/synapseslab/ios-bluegps-sdk-public/releases/download/3.0.0/xcframework.zip",
            checksum: "428bd0f2424de8c36959ed18e9f14b0c6bd91beffb2083707735b03907a50c8e"
        ),
    ]
)
