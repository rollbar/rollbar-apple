// swift-tools-version:5.7.1

import PackageDescription

let package = Package(
    name: "RollbarSDK",
    platforms: [
        .macOS(.v12),
        .iOS(.v14),
        .tvOS(.v14),
        .watchOS(.v8),
    ],
    products: [
        .library(name: "RollbarCommon", targets: ["RollbarCommon"]),
        .library(name: "RollbarNotifier", targets: ["RollbarNotifier", "RollbarCrashReport"]),
        .library(name: "RollbarDeploys", targets: ["RollbarDeploys"]),
        .library(name: "RollbarAUL", targets: ["RollbarAUL"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kstenerud/KSCrash.git", from: "1.15.26"),
    ],
    targets: [
        .target(
            name: "RollbarCommon",
            path: "RollbarCommon/Sources/RollbarCommon",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("RollbarCommon/Sources/RollbarCommon/**"),
            ]),
        .target(
            name: "RollbarCrashReport",
            dependencies: [
                "KSCrash"
            ],
            path: "RollbarNotifier/Sources/RollbarCrashReport"
        ),
        .target(
            name: "RollbarNotifier",
            dependencies: [
                "RollbarCommon",
                "KSCrash",
                "RollbarCrashReport"
            ],
            path: "RollbarNotifier/Sources/RollbarNotifier",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("RollbarNotifier/Sources/RollbarNotifier/**"),
            ]),
        .target(
            name: "RollbarDeploys",
            dependencies: [
                "RollbarCommon",
            ],
            path: "RollbarDeploys/Sources/RollbarDeploys",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("RollbarDeploys/Sources/RollbarDeploys/**"),
            ]),
        .target(
            name: "RollbarAUL",
            dependencies: [
                "RollbarCommon",
                "RollbarNotifier",
            ],
            path: "RollbarAUL/Sources/RollbarAUL",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("RollbarAUL/Sources/RollbarAUL/**"),
            ]),
    ],
    swiftLanguageVersions: [
        SwiftVersion.v5,
    ]
)
