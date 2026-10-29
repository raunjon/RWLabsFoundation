// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RWLabsFoundation",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        // Formatting and convenience helpers for RWLabs apps
        .library(
            name: "RWLabsFoundation",
            targets: ["RWLabsFoundation"]),
    ],
    targets: [
        .target(
            name: "RWLabsFoundation",
            dependencies: []),
        .testTarget(
            name: "RWLabsFoundationTests",
            dependencies: ["RWLabsFoundation"]),
    ],
    swiftLanguageModes: [.v5]
)
