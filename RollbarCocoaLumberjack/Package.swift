// swift-tools-version:5.7.1

import PackageDescription

let package = Package(
    name: "RollbarCocoaLumberjack",
    platforms: [
        .macOS(.v10_13),
        .iOS(.v11),
        .tvOS(.v11),
        .watchOS(.v4),
    ],
    products: [
        .library(
            name: "RollbarCocoaLumberjack",
            targets: ["RollbarCocoaLumberjack"]
        ),
    ],
    dependencies: [
        .package(path: "../RollbarCommon"),
        .package(path: "../RollbarNotifier"),
        .package(path: "../UnitTesting"),
        .package(url: "https://github.com/CocoaLumberjack/CocoaLumberjack.git", from: "3.8.0"),
    ],
    targets: [
        .target(
            name: "RollbarCocoaLumberjack",
            dependencies: [
                "RollbarCommon",
                "RollbarNotifier",
                "CocoaLumberjack",
            ],
            path: "Sources/RollbarCocoaLumberjack"
        ),
        .testTarget(
            name: "RollbarCocoaLumberjackTests",
            dependencies: [
                "UnitTesting",
                "CocoaLumberjack",
                "RollbarCocoaLumberjack",
                .product(name: "CocoaLumberjackSwift", package: "CocoaLumberjack", condition: nil),
            ]
        ),
        .testTarget(
            name: "RollbarCocoaLumberjackTests-ObjC",
            dependencies: ["UnitTesting", "RollbarCocoaLumberjack"],
            path: "Tests/RollbarCocoaLumberjackTests-ObjC"
        ),
    ],
    swiftLanguageVersions: [
        SwiftVersion.v5,
    ]
)
