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
            url: "https://github.com/synapseslab/ios-bluegps-sdk-public/releases/download/3.0.1/xcframework.zip",
            checksum: "0868bac96257ae1ff14507d2c89017e6a1bf08426bdd9cc615f66944c38918cd"
        ),
    ]
)
