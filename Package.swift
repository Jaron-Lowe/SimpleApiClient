// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "SimpleApiClient",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13)
    ],
    products: [
        .library(name: "SimpleApiClient", targets: ["SimpleApiClient"]),
    ],
    dependencies: [],
    targets: [
        .target(name: "SimpleApiClient", dependencies: []),
    ]
)
