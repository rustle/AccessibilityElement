// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "AccessibilityElement",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "AccessibilityElement",
            targets: ["AccessibilityElement"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/rustle/AX.git",
            from: "0.1.1"),
    ],
    targets: [
        .target(
            name: "AccessibilityElement",
            dependencies: [
                "AX",
            ]),
        .testTarget(
            name: "AccessibilityElementTests",
            dependencies: ["AccessibilityElement"]),
    ],
    swiftLanguageVersions: [.v5]
)
