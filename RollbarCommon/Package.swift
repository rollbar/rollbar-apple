// swift-tools-version:5.7.1

import PackageDescription

let package = Package(
    name: "RollbarCommon",
    platforms: [
        .macOS(.v12),
        .iOS(.v14),
        .tvOS(.v14),
        .watchOS(.v8),
    ],
    products: [
        .library(name: "RollbarCommon", targets: ["RollbarCommon"]),
    ],
    targets: [
        .target(
            name: "RollbarCommon",
            path: "Sources/RollbarCommon"
        ),
        .testTarget(
            name: "RollbarCommonTests",
            dependencies: ["RollbarCommon"]
        ),
        .testTarget(
            name: "RollbarCommonTests-ObjC",
            dependencies: ["RollbarCommon"],
            path: "Tests/RollbarCommonTests-ObjC",
            exclude: ["TestData/rollbar-crash-report-147120812218-raw.txt"]
        )
    ],
    swiftLanguageVersions: [
        SwiftVersion.v5,
    ]
)
