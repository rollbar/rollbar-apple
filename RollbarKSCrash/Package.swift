// swift-tools-version:5.7.1

import PackageDescription

let package = Package(
    name: "RollbarKSCrash",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v7),
    ],
    products: [
        .library(name: "RollbarKSCrash", targets: ["RollbarKSCrash"]),
    ],
    dependencies: [
        .package(name:"RollbarCommon", path: "../RollbarCommon"),
        .package(name: "UnitTesting", path: "../UnitTesting"),
        .package(url: "https://github.com/kstenerud/KSCrash.git", from: "1.15.26"),
    ],
    targets: [
        .target(
            name: "RollbarKSCrash",
            dependencies: [
                "RollbarCommon",
                "KSCrash"
            ],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("Sources/RollbarKSCrash/**"),
            ]
        ),
        .testTarget(
            name: "RollbarKSCrashTests",
            dependencies: [
                "UnitTesting",
                "RollbarKSCrash",
            ]
        ),
        .testTarget(
            name: "RollbarKSCrashTests-ObjC",
            dependencies: ["RollbarKSCrash"],
            cSettings: [
                .headerSearchPath("Tests/RollbarKSCrashTests-ObjC/**"),
            ]
        ),
    ],
    swiftLanguageVersions: [
        SwiftVersion.v5,
    ]
)
