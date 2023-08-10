// swift-tools-version:5.7.1

import PackageDescription

let package = Package(
    name: "RollbarDeploys",
    platforms: [
        .macOS(.v10_13),
        .iOS(.v11),
        .tvOS(.v11),
        .watchOS(.v4),
    ],
    products: [
        .library(
            name: "RollbarDeploys",
            targets: ["RollbarDeploys"]),
    ],
    dependencies: [
        .package(path: "../RollbarCommon"),
        .package(path: "../UnitTesting"),
    ],
    targets: [
        .target(
            name: "RollbarDeploys",
            dependencies: ["RollbarCommon"],
            path: "Sources/RollbarDeploys"
        ),
        .testTarget(
            name: "RollbarDeploysTests",
            dependencies: ["UnitTesting", "RollbarDeploys"]
        ),
        .testTarget(
            name: "RollbarDeploysTests-ObjC",
            dependencies: ["UnitTesting", "RollbarDeploys"],
            path: "Tests/RollbarDeploysTests-ObjC"
        ),
    ],
    swiftLanguageVersions: [
        SwiftVersion.v5,
    ]
)
