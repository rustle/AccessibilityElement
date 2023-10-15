// swift-tools-version:5.9

import PackageDescription

let package = Package(
    name: "AccessibilityElement",
    platforms: [
        .macOS(.v14),
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
            from: "0.1.9"),
        .package(
            url: "https://github.com/apple/swift-atomics.git",
            .upToNextMajor(from: "1.0.0")),
        .package(
            url: "https://github.com/apple/swift-collections.git",
            .upToNextMajor(from: "1.0.3")),
        .package(
            url: "https://github.com/reddavis/Asynchrone",
            from: "0.21.0"),
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
                "Asynchrone",
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
