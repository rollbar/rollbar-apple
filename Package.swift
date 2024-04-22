// swift-tools-version:5.7.1

import PackageDescription

let package = Package(
    name: "RollbarSDK",
    platforms: [
        .macOS(.v10_13),
        .iOS(.v11),
        .tvOS(.v11),
        .watchOS(.v4),
    ],
    products: [
        .library(name: "RollbarCommon", targets: ["RollbarCommon"]),
        .library(name: "RollbarNotifier", targets: ["RollbarCrash", "RollbarReport", "RollbarNotifier"]),
        .library(name: "RollbarDeploys", targets: ["RollbarDeploys"]),
        .library(name: "RollbarAUL", targets: ["RollbarAUL"]),
        .library(name: "RollbarCocoaLumberjack", targets: ["RollbarCocoaLumberjack"]),
    ],
    dependencies: [
        .package(url: "https://github.com/CocoaLumberjack/CocoaLumberjack.git", from: "3.8.0"),
    ],
    targets: [
        .target(
            name: "RollbarCommon",
            path: "RollbarCommon/Sources/RollbarCommon",
            resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
        .target(
            name: "RollbarCrash",
            dependencies: [],
            path: "RollbarNotifier/Sources/RollbarCrash",
            resources: [.copy("PrivacyInfo.xcprivacy")],
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
            name: "RollbarReport",
            dependencies: ["RollbarCrash"],
            path: "RollbarNotifier/Sources/RollbarReport"
        ),
        .target(
            name: "RollbarNotifier",
            dependencies: [
                "RollbarCommon",
                "RollbarCrash",
                "RollbarReport"
            ],
            path: "RollbarNotifier/Sources/RollbarNotifier",
            resources: [.copy("PrivacyInfo.xcprivacy")]
        ),
        .target(
            name: "RollbarDeploys",
            dependencies: ["RollbarCommon"],
            path: "RollbarDeploys/Sources/RollbarDeploys"
        ),
        .target(
            name: "RollbarAUL",
            dependencies: [
                "RollbarCommon",
                "RollbarNotifier",
            ],
            path: "RollbarAUL/Sources/RollbarAUL"
        ),
        .target(
            name: "RollbarCocoaLumberjack",
            dependencies: [
                "RollbarCommon",
                "RollbarNotifier",
                "CocoaLumberjack",
            ],
            path: "RollbarCocoaLumberjack/Sources/RollbarCocoaLumberjack"
        ),
    ],
    swiftLanguageVersions: [
        SwiftVersion.v5,
    ],
    cxxLanguageStandard: .cxx17
)
