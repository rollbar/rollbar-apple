// swift-tools-version:5.7.1

import PackageDescription

let package = Package(
    name: "RollbarNotifier",
    platforms: [
        .macOS(.v12),
        .iOS(.v14),
        .tvOS(.v14),
        .watchOS(.v8),
    ],
    products: [
        .library(
            name: "RollbarNotifier",
            targets: ["RollbarCrash", "RollbarNotifier", "RollbarCrashReport"]
        ),
    ],
    dependencies: [
        .package(path: "../RollbarCommon"),
        .package(path: "../UnitTesting"),
    ],
    targets: [
        .target(
            name: "RollbarCrash",
            dependencies: [],
            path: "Sources/RollbarCrash",
            publicHeadersPath: "include",
            cxxSettings: [
                .define("GCC_ENABLE_CPP_EXCEPTIONS", to: "YES"),
                .headerSearchPath("./**")
            ]
        ),
        .target(
            name: "RollbarCrashReport",
            dependencies: [
                "RollbarCrash"
            ],
            path: "Sources/RollbarCrashReport"
        ),
        .target(
            name: "RollbarNotifier",
            dependencies: [
                "RollbarCommon",
                "RollbarCrash",
                "RollbarCrashReport"
            ],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("Sources/RollbarNotifier/**"),
            ]
        ),
        .testTarget(
            name: "RollbarCrashReportTests",
            dependencies: ["RollbarCrashReport"],
            resources: [.process("Assets")]
        ),
        .testTarget(
            name: "RollbarNotifierTests",
            dependencies: [
                "UnitTesting",
                "RollbarNotifier"
            ]
        ),
        .testTarget(
            name: "RollbarNotifierTests-ObjC",
            dependencies: [
                "UnitTesting",
                "RollbarNotifier",
            ],
            cSettings: [
                .headerSearchPath("Tests/RollbarNotifierTests-ObjC/**"),
            ]
        ),
    ],
    swiftLanguageVersions: [
        SwiftVersion.v5
    ],
    cxxLanguageStandard: .cxx17
)
