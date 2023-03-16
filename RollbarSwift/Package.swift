// swift-tools-version:5.7.1

import PackageDescription

let package = Package(
    name: "RollbarSwift",
    platforms: [
        .macOS(.v12),
        .iOS(.v14),
        .tvOS(.v14),
        .watchOS(.v8),
    ],
    products: [
        .library(
            name: "RollbarSwift",
            targets: ["RollbarSwift"]),
    ],
    dependencies: [
        .package(path: "../RollbarCommon"),
        .package(path: "../RollbarNotifier"),
        .package(name: "UnitTesting",
                 path: "../UnitTesting"
                ),
    ],
    targets: [
        .target(
            name: "RollbarSwift",
            dependencies: ["RollbarCommon", "RollbarNotifier",],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("Sources/RollbarSwift/**"),
            ]
        ),
        .testTarget(
            name: "RollbarSwiftTests",
            dependencies: [
                "UnitTesting",
                "RollbarSwift",
            ]
        ),
        .testTarget(
            name: "RollbarSwiftTests-ObjC",
            dependencies: ["RollbarSwift"],
            cSettings: [
                .headerSearchPath("Tests/RollbarSwiftTests-ObjC/**"),
            ]
        ),
    ],
    swiftLanguageVersions: [
        SwiftVersion.v5,
    ]
)
