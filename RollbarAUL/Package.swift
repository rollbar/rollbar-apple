// swift-tools-version:5.7.1

import PackageDescription

let package = Package(
    name: "RollbarAUL",
    platforms: [
        .macOS(.v12),
        .iOS(.v14),
        .tvOS(.v14),
        .watchOS(.v8),
    ],
    products: [
        .library(
            name: "RollbarAUL",
            targets: ["RollbarAUL"]),
    ],
    dependencies: [
        .package(path: "../RollbarCommon"),
        .package(path: "../RollbarNotifier"),
        .package(path: "../UnitTesting"),
    ],
    targets: [
        .target(
            name: "RollbarAUL",
            dependencies: ["RollbarCommon", "RollbarNotifier"],
            path: "Sources/RollbarAUL",
            publicHeadersPath: "include"
        ),
        .testTarget(
            name: "RollbarAULTests",
            dependencies: ["UnitTesting", "RollbarAUL"]
        ),
        .testTarget(
            name: "RollbarAULTests-ObjC",
            dependencies: ["UnitTesting", "RollbarAUL"],
            path: "Tests/RollbarAULTests-ObjC"
        ),
    ],
    swiftLanguageVersions: [
        SwiftVersion.v5,
    ]
)
