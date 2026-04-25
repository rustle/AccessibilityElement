// swift-tools-version:6.2

import PackageDescription

let package = Package(
    name: "AccessibilityElement",
    platforms: [
        .macOS(.v15),
    ],
    products: [
        .library(
            name: "AccessibilityElement",
            targets: ["AccessibilityElement"]
        ),
        .library(
            name: "AccessibilityElementMocks",
            targets: ["AccessibilityElementMocks"]
        ),
        .executable(
            name: "SystemObserverExample",
            targets: ["SystemObserverExample"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/rustle/AX.git",
            .upToNextMajor(from: "0.2.1")
        ),
        .package(
            url: "https://github.com/apple/swift-atomics.git",
            .upToNextMajor(from: "1.2.0")
        ),
        .package(
            url: "https://github.com/rustle/RunLoopExecutor.git",
            .upToNextMajor(from: "1.0.0")
        ),
    ],
    targets: [
        .target(
            name: "AccessibilityElement",
            dependencies: [
                "AX",
                .product(
                    name: "Atomics",
                    package: "swift-atomics"
                ),
                "RunLoopExecutor",
            ]
        ),
        .target(
            name: "AccessibilityElementMocks",
            dependencies: [
                "AccessibilityElement",
                .product(name: "Atomics",
                         package: "swift-atomics"),
            ]),
        .executableTarget(
            name: "SystemObserverExample",
            dependencies: ["AccessibilityElement"]
        ),
        .testTarget(
            name: "AccessibilityElementTests",
            dependencies: ["AccessibilityElement"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
