// swift-tools-version:5.7.1

import PackageDescription

let package = Package(
    name: "RollbarNotifier",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v7),
    ],
    products: [
        .library(name: "RollbarNotifier", targets: ["RollbarNotifier"]),
    ],
    dependencies: [
        .package(path: "../RollbarCommon"),
        .package(path: "../UnitTesting"),
        .package(url: "https://github.com/kstenerud/KSCrash.git", from: "1.15.26"),
    ],
    targets: [
        .target(
            name: "RollbarNotifier",
            dependencies: [
                "RollbarCommon",
                "KSCrash",
            ],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("Sources/RollbarNotifier/**"),
            ]
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
