// swift-tools-version:5.7.1

import PackageDescription

let package = Package(
    name: "UnitTesting",
    platforms: [
        .macOS(.v12),
        .iOS(.v14),
        .tvOS(.v14),
        .watchOS(.v8),
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
            dependencies: [
                "RollbarCommon",
            ],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("Sources/UnitTesting/**"),
            ]
        ),
        .testTarget(
            name: "UnitTestingTests",
            dependencies: ["UnitTesting"]),
    ],
    swiftLanguageVersions: [
        SwiftVersion.v5,
    ]
)
