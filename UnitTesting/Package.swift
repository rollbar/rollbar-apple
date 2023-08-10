// swift-tools-version:5.7.1

import PackageDescription

let package = Package(
    name: "UnitTesting",
    platforms: [
        .macOS(.v10_13),
        .iOS(.v11),
        .tvOS(.v11),
        .watchOS(.v4),
    ],
    products: [
        .library(
            name: "UnitTesting",
            targets: ["UnitTesting"]),
    ],
    dependencies: [
        .package(path: "../RollbarCommon"),
    ],
    targets: [
        .target(
            name: "UnitTesting",
            dependencies: ["RollbarCommon"],
            path: "Sources/UnitTesting"
        ),
        .testTarget(
            name: "UnitTestingTests",
            dependencies: ["UnitTesting"]
        ),
    ],
    swiftLanguageVersions: [
        SwiftVersion.v5,
    ]
)
