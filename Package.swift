// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SwiftKunai",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "SwiftKunai",
            targets: ["SwiftKunai"]
        ),
    ],
    targets: [
        .target(
            name: "SwiftKunai"
        ),
        .testTarget(
            name: "SwiftKunaiTests",
            dependencies: ["SwiftKunai"]
        ),
    ]
)


