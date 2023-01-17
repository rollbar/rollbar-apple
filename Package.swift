// swift-tools-version:5.7.1

import PackageDescription

let package = Package(
    name: "RollbarSDK",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v7),
    ],
    products: [
        .library(name: "RollbarCommon", targets: ["RollbarCommon"]),
        .library(name: "RollbarNotifier", targets: ["RollbarNotifier"]),
        .library(name: "RollbarSwift", targets: ["RollbarSwift"]),
        .library(name: "RollbarDeploys", targets: ["RollbarDeploys"]),
        .library(name: "RollbarAUL", targets: ["RollbarAUL"]),
        .library(name: "RollbarCocoaLumberjack", targets: ["RollbarCocoaLumberjack"]),
    ],
    dependencies: [
        .package(url: "https://github.com/kstenerud/KSCrash.git", from: "1.15.26"),
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
            name: "RollbarNotifier",
            dependencies: [
                "RollbarCommon",
                "KSCrash",
            ],
            path: "RollbarNotifier/Sources/RollbarNotifier",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("RollbarNotifier/Sources/RollbarNotifier/**"),
            ]),
        .target(
            name: "RollbarSwift",
            dependencies: [
                "RollbarCommon",
                "RollbarNotifier",
            ],
            path: "RollbarSwift/Sources/RollbarSwift",
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("RollbarSwift/Sources/RollbarSwift/**"),
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
                .headerSearchPath("RollbarCocoaLumberjack/Sources/RollbarCocoaLumberjack/**"),
            ]
        ),
    ],
    swiftLanguageVersions: [
        SwiftVersion.v5,
    ]
)
