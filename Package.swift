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
        .library(name: "RollbarNotifier", targets: ["RollbarCrash", "RollbarCrashReport", "RollbarNotifier"]),
        .library(name: "RollbarDeploys", targets: ["RollbarDeploys"]),
        .library(name: "RollbarAUL", targets: ["RollbarAUL"]),
        .library(name: "RollbarCocoaLumberjack", targets: ["RollbarCocoaLumberjack"]),
    ],
    dependencies: [
        .package(url: "https://github.com/CocoaLumberjack/CocoaLumberjack.git", from: "3.7.4"),
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
            name: "RollbarCrash",
            dependencies: [],
            path: "RollbarNotifier/Sources/RollbarCrash",
            publicHeadersPath: "include",
            cxxSettings: [
                .define("GCC_ENABLE_CPP_EXCEPTIONS", to: "YES"),
                .headerSearchPath("Monitors"),
                .headerSearchPath("Recording"),
                .headerSearchPath("Util")
            ],
            linkerSettings: [
                .linkedLibrary("c++"),
                .linkedLibrary("z")
            ]
        ),
        .target(
            name: "RollbarCrashReport",
            dependencies: ["RollbarCrash"],
            path: "RollbarNotifier/Sources/RollbarCrashReport"
        ),
        .target(
            name: "RollbarNotifier",
            dependencies: [
                "RollbarCommon",
                "RollbarCrash",
                "RollbarCrashReport"
            ],
            path: "RollbarNotifier/Sources/RollbarNotifier",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("./**"),
            ]),
        .target(
            name: "RollbarDeploys",
            dependencies: [
                "RollbarCommon",
            ],
            path: "RollbarDeploys/Sources/RollbarDeploys",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("./**"),
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
                .headerSearchPath("./**"),
            ]),
        .target(
            name: "RollbarCocoaLumberjack",
            dependencies: [
                "RollbarCommon",
                "RollbarNotifier",
                "CocoaLumberjack",
            ],
            path: "RollbarCocoaLumberjack/Sources/RollbarCocoaLumberjack",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("./**"),
            ]
        ),
    ],
    swiftLanguageVersions: [
        SwiftVersion.v5,
    ],
    cxxLanguageStandard: .cxx17
)
