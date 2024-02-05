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
            checksum: "f4bb9156d999ddae0a04f9f7d688b5330349dbe929bcd4bf40ce237faf5e8ad7"
        ),
    ]
)
