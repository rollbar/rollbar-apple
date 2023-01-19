// swift-tools-version:5.7.1

import PackageDescription

let package = Package(
    name: "RollbarCommon",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v7),
    ],
    products: [
        .library(
            name: "RollbarCommon",
            targets: ["RollbarCommon", "RollbarCrashReport"]),
    ],
    targets: [
        .target(
            name: "RollbarCommon",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("Sources/RollbarCommon/**"),
            ]),
        .target(
            name: "RollbarCrashReport",
            path: "Sources/RollbarCrashReport"),
        .testTarget(
            name: "RollbarCommonTests",
            dependencies: ["RollbarCommon"]),
        .testTarget(
            name: "RollbarCommonTests-ObjC",
            dependencies: ["RollbarCommon"],
            exclude: ["TestData/rollbar-crash-report-147120812218-raw.txt"],
            cSettings: [
                .headerSearchPath("Tests/RollbarCommonTests-ObjC/**"),
            ]),
        .testTarget(
            name: "RollbarCrashReportTests",
            dependencies: ["RollbarCrashReport"]),
    ],
    swiftLanguageVersions: [
        SwiftVersion.v5,
    ]
)
