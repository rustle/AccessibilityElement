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
    ],
    targets: [
        .target(
            name: "AccessibilityElement",
            dependencies: []),
        .testTarget(
            name: "AccessibilityElementTests",
            dependencies: ["AccessibilityElement"]),
    ],
    swiftLanguageVersions: [.v5]
)
