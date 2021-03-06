// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "AccessibilityElement",
    platforms: [
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "AccessibilityElement",
            targets: ["AccessibilityElement"]),
    ],
    dependencies: [
        .package(url: "https://github.com/rustle/SwiftScanner.git",
                 from: "1.0.3+"),
    ],
    targets: [
        .target(
            name: "AccessibilityElement",
            dependencies: ["SwiftScanner"]),
        .testTarget(
            name: "AccessibilityElementTests",
            dependencies: ["AccessibilityElement"]),
    ],
    swiftLanguageVersions: [.v5]
)
