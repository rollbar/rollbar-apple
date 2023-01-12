// swift-tools-version:5.7.1
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RollbarCocoaLumberjack",
    platforms: [
        // Oldest targeted platform versions that are supported by this product.
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v7),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "RollbarCocoaLumberjack",
            targets: ["RollbarCocoaLumberjack"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(path: "../RollbarCommon"),
        .package(path: "../RollbarNotifier"),
        .package(path: "../UnitTesting"),
        .package(url: "https://github.com/CocoaLumberjack/CocoaLumberjack.git", from: "3.7.4"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "RollbarCocoaLumberjack",
            dependencies: [
                "RollbarCommon",
                "RollbarNotifier",
                "CocoaLumberjack",
            ],
            publicHeadersPath: "include",
            cSettings: [
                .headerSearchPath("Sources/RollbarCocoaLumberjack/**"),
                //                .headerSearchPath("Sources/RollbarCocoaLumberjack/DTOs"),
                //                .define("DEFINES_MODULE"),
            ]
        ),
        .testTarget(
            name: "RollbarCocoaLumberjackTests",
            dependencies: [
                "UnitTesting",
                "CocoaLumberjack",
                "RollbarCocoaLumberjack",
                .product(name: "CocoaLumberjackSwift", package: "CocoaLumberjack", condition: nil),
            ]
        ),
        .testTarget(
            name: "RollbarCocoaLumberjackTests-ObjC",
            dependencies: [
                "UnitTesting",
                "RollbarCocoaLumberjack",
            ],
            cSettings: [
                .headerSearchPath("Tests/RollbarCocoaLumberjackTests-ObjC/**"),
            ]
        ),
    ],
    swiftLanguageVersions: [
        SwiftVersion.v4,
        SwiftVersion.v4_2,
        SwiftVersion.v5,
    ]
)
