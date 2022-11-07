// swift-tools-version:5.7

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
        .library(
            name: "AccessibilityElementMocks",
            targets: ["AccessibilityElementMocks"]),
        .executable(
            name: "SystemObserverExample",
            targets: ["SystemObserverExample"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/rustle/AX.git",
            from: "0.1.8"),
        .package(
            url: "https://github.com/apple/swift-atomics.git",
            .upToNextMajor(from: "1.0.0")),
        .package(
            url: "https://github.com/apple/swift-collections.git",
            .upToNextMajor(from: "1.0.3")),
    ],
    targets: [
        .target(
            name: "AccessibilityElement",
            dependencies: [
                "AX",
                .product(
                    name: "Atomics",
                    package: "swift-atomics"),
                .product(
                    name: "Collections",
                    package: "swift-collections"),
            ]),
        .target(
            name: "AccessibilityElementMocks",
            dependencies: [
                "AccessibilityElement",
            ]),
        .executableTarget(
            name: "SystemObserverExample",
            dependencies: ["AccessibilityElement"]),
        .testTarget(
            name: "AccessibilityElementTests",
            dependencies: ["AccessibilityElement"]),
    ],
    swiftLanguageVersions: [.v5]
)
