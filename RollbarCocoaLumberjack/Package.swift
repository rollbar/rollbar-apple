// swift-tools-version:5.7.1

import PackageDescription

let package = Package(
    name: "RollbarCocoaLumberjack",
    platforms: [
        .macOS(.v12),
        .iOS(.v14),
        .tvOS(.v14),
        .watchOS(.v8),
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
        .package(url: "https://github.com/CocoaLumberjack/CocoaLumberjack.git", from: "3.7.4"),
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
