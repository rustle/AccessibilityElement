// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "AccessibilityElement",
    products: [
        .library(
            name: "AccessibilityElement",
            targets: ["AccessibilityElement"]),
    ],
    dependencies: [
        .package(url: "https://github.com/rustle/CoreFoundationOverlay.git", from: "1.0.0"),
        .package(url: "https://github.com/rustle/Signals.git", .revision("37445e0039defc57f8914ed521d2c1a0772fe992")),
        .package(url: "https://github.com/rustle/SwiftScanner.git", from: "1.0.3+"),
        .package(url: "https://github.com/glessard/swift-atomics", from: "4.0.0"),
    ],
    targets: [
        .target(
            name: "AccessibilityElement",
            dependencies: ["CoreFoundationOverlay", "Signals", "SwiftScanner", "Atomics"]),
        .testTarget(
            name: "AccessibilityElementTests",
            dependencies: ["AccessibilityElement"]),
    ],
    swiftLanguageVersions: [4]
)
