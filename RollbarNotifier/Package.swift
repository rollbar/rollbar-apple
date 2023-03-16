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
        .library(name: "RollbarNotifier", targets: ["RollbarNotifier", "RollbarCrashReport"]),
    ],
    dependencies: [
        .package(path: "../RollbarCommon"),
        .package(path: "../UnitTesting"),
        .package(url: "https://github.com/kstenerud/KSCrash.git", from: "1.15.26"),
    ],
    targets: [
        .target(
            name: "RollbarCrashReport",
            dependencies: [
                "KSCrash",
            ],
            path: "Sources/RollbarCrashReport"
        ),
        .target(
            name: "RollbarNotifier",
            dependencies: [
                "RollbarCommon",
                "KSCrash",
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
        SwiftVersion.v5,
    ]
)
